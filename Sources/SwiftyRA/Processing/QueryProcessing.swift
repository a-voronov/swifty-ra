public extension Query {
    // TODO: should run optimization on each execution step?
    func execute() -> Relation.Throws<Relation> {
        switch self {
        case let .projection(attrs, q):           return applyUnary(q, project(attributes: attrs))
        case let .selection(predicate, q):        return applyUnary(q, select(where: predicate))
        case let .rename(to, from, q):            return applyUnary(q, rename(to: to, from: from))
        case let .orderBy(attrs, q):              return applyUnary(q, orderBy(attributes: attrs))
        case let .intersection(lhs, rhs):         return applyBinary(lhs, rhs, intersect)
        case let .union(lhs, rhs):                return applyBinary(lhs, rhs, union)
        case let .subtraction(lhs, rhs):          return applyBinary(lhs, rhs, subtract)
        case let .product(lhs, rhs):              return applyBinary(lhs, rhs, product)
        case let .division(lhs, rhs):             return applyBinary(lhs, rhs, divide)
        case let .join(.natural, lhs, rhs):       return applyBinary(lhs, rhs, naturalJoin)
        case let .join(.theta(p), lhs, rhs):      return applyBinary(lhs, rhs, thetaJoin(where: p))
        case let .join(.semi(.left), lhs, rhs):   return applyBinary(lhs, rhs, leftSemiJoin)
        case let .join(.semi(.right), lhs, rhs):  return applyBinary(lhs, rhs, rightSemiJoin)
        case let .join(.semi(.anti), lhs, rhs):   return applyBinary(lhs, rhs, antiSemiJoin)
        case let .relation(r):                    return .success(r)
        }
    }

    private func applyUnary(_ q: Query, _ op: (Relation) -> Relation.Throws<Relation>) -> Relation.Throws<Relation> {
        q.execute().flatMap(op)
    }

    private func applyBinary(
        _ lhs: Query,
        _ rhs: Query,
        _ op: (Relation, Relation) -> Relation.Throws<Relation>
    ) -> Relation.Throws<Relation> {
        zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(op)
    }

    private func project(attributes: Set<AttributeName>) -> (Relation) -> Relation.Throws<Relation> {
        return { r in r.state.flatMap { s in
            var projectedAttributes: [Attribute] = []
            var errors: Set<AttributeName> = []

            for attributeName in attributes {
                guard let attribute = s.header[attributeName] else {
                    errors.insert(attributeName)
                    continue
                }
                projectedAttributes.append(attribute)
            }
            if let errs = errors.decompose().map(OneOrMore.few) {
                return .failure(.query(.unknownAttributes(errs)))
            }
            return Header.create(attributes: projectedAttributes)
                .mapError(Relation.Errors.header)
                .map { header in
                    let tuples = s.tuples.map { tuple in
                        Tuple(values: attributes.reduce(into: [:]) { acc, attributeName in
                            acc[attributeName] = tuple[attributeName, default: .none]
                        })
                    }
                    return Relation(header: header, tuples: tuples)
                }
        }}
    }

    private func select(where predicate: Query.Predicate) -> (Relation) -> Relation.Throws<Relation> {
        return { r in r.state.flatMap { s in
            let errors = predicate.attributes.subtracting(s.header.attributes.map(\.name))
            if let errs = errors.decompose().map(OneOrMore.few) {
                return .failure(.query(.unknownAttributes(errs)))
            }
            return s.tuples
                .filter { predicate.execute(with: Query.Predicate.Context(values: $0.values)) }
                .mapError(Query.Errors.predicate)
                .mapError(Relation.Errors.query)
                .map { Relation(header: s.header, tuples: $0) }
        }}
    }

    private func rename(to new: AttributeName, from original: AttributeName) -> (Relation) -> Relation.Throws<Relation> {
        return { r in r.state.flatMap { s in
            guard let originalAttr = s.header[original], let originalIndex = s.header.attributes.firstIndex(of: originalAttr) else {
                return .failure(.query(.unknownAttributes(.one(original))))
            }
            var attributes = s.header.attributes
            attributes[originalIndex] = Attribute(name: new, type: originalAttr.type)
            // header better be created first to fail early if something is wrong with attributes
            return Header.create(attributes: attributes)
                .mapError(Relation.Errors.header)
                .map { header in
                    // TODO: can be paralleled for big amount of tuples with DispatchGroup (if there's such in swift-corelibs)
                    let tuples = s.tuples.map { tuple in
                        updating(tuple) { $0.rename(to: new, from: original) }
                    }
                    return Relation(header: header, tuples: tuples)
                }
        }}
    }

    private func orderBy(attributes: [Pair<AttributeName, Query.SortingOrder>]) -> (Relation) -> Relation.Throws<Relation> {
        return { r in r.state.flatMap { s in
            let unknownAttributes = Set(attributes.map(\.left)).subtracting(s.header.attributes.map(\.name))
            if let errors = unknownAttributes.decompose().map(OneOrMore.few) {
                return .failure(.query(.unknownAttributes(errors)))
            }
            return s.tuples.sorted { lhs, rhs in
                for (attribute, order) in attributes.map(\.both) {
                    let l = lhs[attribute, default: .none]
                    let r = rhs[attribute, default: .none]

                    guard l != r else {
                        continue
                    }

                    switch order {
                    case .asc:  return l < r
                    case .desc: return l > r
                    }
                }
                return .success(false)
            }
            .mapError(Relation.Errors.value)
            .map { Relation(header: s.header, tuples: $0) }
        }}
    }

    private func intersect(_ one: Relation, with another: Relation) -> Relation.Throws<Relation> {
        executeUnionCompatibleOperation(with: one, and: another) { $0.intersection($1) }
    }

    private func union(_ one: Relation, with another: Relation) -> Relation.Throws<Relation> {
        executeUnionCompatibleOperation(with: one, and: another) { $0.union($1) }
    }

    private func subtract(_ one: Relation, and another: Relation) -> Relation.Throws<Relation> {
        executeUnionCompatibleOperation(with: one, and: another) { $0.subtracting($1) }
    }

    private func executeUnionCompatibleOperation(with one: Relation, and another: Relation, operation: (Tuples, Tuples) -> Tuples) -> Relation.Throws<Relation> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            guard l.header == r.header else {
                guard let (lErrs, rErrs) = zip(l.header.attributes.decompose(), r.header.attributes.decompose()).map(OneOrMore.tupleOfFew) else {
                    return .failure(.header(.empty))
                }
                return .failure(.query(.attributesNotUnionCompatible(lErrs, rErrs)))
            }
            let tuples = operation(l.tuples, r.tuples)
            return .success(Relation(header: l.header, tuples: tuples))
        }
    }

    private func product(_ one: Relation, with another: Relation) -> Relation.Throws<Relation> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            let lAttrs = l.header.attributes
            let rAttrs = r.header.attributes
            guard Set(lAttrs).isDisjoint(with: rAttrs) else {
                guard let (lErrs, rErrs) = zip(lAttrs.decompose(), rAttrs.decompose()).map(OneOrMore.tupleOfFew) else {
                    return .failure(.header(.empty))
                }
                return .failure(.query(.attributesNotDisjointed(lErrs, rErrs)))
            }
            return Header.create(attributes: lAttrs + rAttrs)
                .mapError(Relation.Errors.header)
                .map { header in
                    let tuples = l.tuples.flatMap { lt in
                        r.tuples.map { rt in
                            Tuple(values: lt.values.merging(rt.values, uniquingKeysWith: { orig, _ in orig }))
                        }
                    }
                    return Relation(header: header, tuples: tuples)
                }
        }
    }

    private func divide(_ one: Relation, by another: Relation) -> Relation.Throws<Relation> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            let lAttrs = l.header.attributes
            let rAttrs = r.header.attributes
            guard Set(lAttrs).isSuperset(of: rAttrs) else {
                guard let (lErrs, rErrs) = zip(lAttrs.decompose(), rAttrs.decompose()).map(OneOrMore.tupleOfFew) else {
                    return .failure(.header(.empty))
                }
                return .failure(.query(.attributesNotSupersetToAnother(lErrs, rErrs)))
            }
            let uniqueAttributes = Set(Set(lAttrs).subtracting(rAttrs).map(\.name))

            let ur = Query.projection(uniqueAttributes, .relation(one))
            let t = Query.product(ur, .relation(another))
            let u = Query.subtraction(t, .relation(one))
            let v = Query.projection(uniqueAttributes, u)
            let w = Query.subtraction(ur, v)

            return w.execute()
        }
    }

    private func naturalJoin(_ one: Relation, and another: Relation) -> Relation.Throws<Relation> {
        innerJoin(one, and: another, on: nil)
    }

    private func thetaJoin(where predicate: Query.Predicate) -> (Relation, Relation) -> Relation.Throws<Relation> {
        return { one, another in
            self.innerJoin(one, and: another, on: predicate)
        }
    }

    private func innerJoin(_ one: Relation, and another: Relation, on predicate: Query.Predicate?) -> Relation.Throws<Relation> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            let lAttrs = l.header.attributes.map(\.name)
            let rAttrs = r.header.attributes.map(\.name)
            let attributeNamesUnion = Set(lAttrs).union(rAttrs)
            var attributes: [Attribute] = []
            var errors: [Pair<Attribute, Attribute>] = []

            for attributeName in attributeNamesUnion {
                switch (l.header[attributeName], r.header[attributeName]) {
                case let (lhs?, rhs?):
                    if lhs == rhs {
                        attributes.append(lhs)
                    } else {
                        errors.append(Pair(lhs, rhs))
                    }
                case let (lhs?, nil):
                    attributes.append(lhs)
                case let (nil, rhs?):
                    attributes.append(rhs)
                case (nil, nil):
                    // this case won't happen, as attributes are taken from both headers only, but we need to satisfy compiler
                    return .failure(.query(.unknownAttributes(.one(attributeName))))
                }
            }

            if let errs = errors.decompose().map(OneOrMore.few) {
                return .failure(.query(.incompatibleAttributes(errs)))
            }

            return Header.create(attributes: attributes)
                .mapError(Relation.Errors.header)
                .flatMap { header in
                    let commonAttributeNames = Set(lAttrs).intersection(rAttrs)
                    let tuples = l.tuples.flatMap { lt in
                        r.tuples.compactMap { rt -> Result<Tuple?, Relation.Errors> in
                            let shouldJoin = commonAttributeNames.reduce(true) { acc, attribute in
                                acc && lt[attribute] == rt[attribute]
                            }
                            let values = lt.values.merging(rt.values, uniquingKeysWith: { orig, _ in orig })
                            let result = predicate?.execute(with: Query.Predicate.Context(values: values)) ?? .success(true)
                            return result
                                .mapError(Query.Errors.predicate)
                                .mapError(Relation.Errors.query)
                                .map { res in shouldJoin && res ? Tuple(values: values) : nil }
                        }
                    }
                    return tuples.map { Relation(header: header, tuples: $0) }
                }
        }
    }

    private func leftSemiJoin(_ one: Relation, and another: Relation) -> Relation.Throws<Relation> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            let lAttrs = l.header.attributes.map(\.name)
            return Query.projection(Set(lAttrs), .join(.natural, .relation(one), .relation(another))).execute()
        }
    }

    private func rightSemiJoin(_ one: Relation, and another: Relation) -> Relation.Throws<Relation> {
        leftSemiJoin(another, and: one)
    }

    private func antiSemiJoin(_ one: Relation, and another: Relation) -> Relation.Throws<Relation> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            Query.subtraction(.relation(one), .join(.semi(.left), .relation(one), .relation(another))).execute()
        }
    }
}
