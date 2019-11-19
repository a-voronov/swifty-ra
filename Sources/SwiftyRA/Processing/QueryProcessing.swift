public extension Query {
    // TODO: should run optimization on each execution step?
    func execute() -> Relation.Throws<Relation> {
        switch self {
        case let .projection(args, q):           return applyUnary(q, project(arguments: args))
        case let .selection(predicate, q):       return applyUnary(q, select(where: predicate))
        case let .rename(to, from, q):           return applyUnary(q, rename(to: to, from: from))
        case let .orderBy(attrs, q):             return applyUnary(q, orderBy(attributes: attrs))
        case let .intersection(lhs, rhs):        return applyBinary(lhs, rhs, intersect)
        case let .union(lhs, rhs):               return applyBinary(lhs, rhs, union)
        case let .subtraction(lhs, rhs):         return applyBinary(lhs, rhs, subtract)
        case let .product(lhs, rhs):             return applyBinary(lhs, rhs, product)
        case let .division(lhs, rhs):            return applyBinary(lhs, rhs, divide)
        case let .join(.natural, lhs, rhs):      return applyBinary(lhs, rhs, naturalJoin)
        case let .join(.theta(exp), lhs, rhs):   return applyBinary(lhs, rhs, thetaJoin(where: exp))
        case let .join(.semi(.left), lhs, rhs):  return applyBinary(lhs, rhs, leftSemiJoin)
        case let .join(.semi(.right), lhs, rhs): return applyBinary(lhs, rhs, rightSemiJoin)
        case let .join(.semi(.anti), lhs, rhs):  return applyBinary(lhs, rhs, antiSemiJoin)
        case let .just(r):                       return .success(r)
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
        zip(lhs.execute(), rhs.execute()).flatMap(op)
    }

    private func project(arguments: Query.ProjectionArguments) -> (Relation) -> Relation.Throws<Relation> {
        return { r in r.state.flatMap { s in
            var attributeTypes: [AttributeName: AttributeType] = [:]
            // Checking for duplicates
            var duplicates: Set<AttributeName> = []
            let expressions: [AttributeName: AnyExpression] = arguments.reduce(into: [:]) { acc, arg in
                guard acc[arg.attribute] == nil else {
                    duplicates.insert(arg.attribute)
                    return
                }
                if let expression = arg.expression {
                    acc[arg.attribute] = expression
                } else {
                    acc[arg.attribute] = .member(.atr(arg.attribute))
                    attributeTypes[arg.attribute] = s.header[arg.attribute]?.type
                }
            }
            if let dups = duplicates.decompose().map(OneOrMore.few) {
                return .failure(.query(.duplicatedAttributes(dups)))
            }
            // Checking for unknown attributes
            let attributes: Set<AttributeName> = expressions.values.reduce([]) { acc, exp in
                acc.union(exp.attributes)
            }
            let unknown = attributes.compactMap { attribute in
                s.header[attribute] == nil
                    ? attribute
                    : nil
            }
            if let errs = unknown.decompose().map(OneOrMore.few) {
                return .failure(.query(.unknownAttributes(errs)))
            }
            // Constructing new tuples and inferring scheme type
            let tuples = s.tuples.map { tuple -> AnyExpression.Throws<Tuple> in
                let ctx = ExpressionContext(values: tuple.values)
                var values: [AttributeName: Value] = [:]

                for (attribute, expression) in expressions {
                    switch expression.execute(with: ctx) {
                    case let .success(value):
                        values[attribute] = value

                        switch (value.type, attributeTypes[attribute]) {
                        case let (valueType?, nil): attributeTypes[attribute] = .required(valueType)
                        case let (nil, .required(valueType)): attributeTypes[attribute] = .optional(valueType)
                        case let (valueType?, attributeType?):
                            guard valueType == attributeType.valueType else {
                                return .failure(.value(.mismatch(.one(value), .one(attributeType.valueType))))
                            }
                        default: break
                        }
                    case let .failure(error):
                        return .failure(error)
                    }
                }
                return .success(Tuple(values: values))
            }
            // Checking scheme type
            var typeInferringErrors: [AttributeName] = []
            let projectedAttributes: [Attribute] = arguments.compactMap { arg in
                guard let attributeType = attributeTypes[arg.attribute] else {
                    typeInferringErrors.append(arg.attribute)
                    return nil
                }
                return Attribute(name: arg.attribute, type: attributeType)
            }
            if let errs = typeInferringErrors.decompose().map(OneOrMore.few) {
                return .failure(.query(.typeInferring(errs)))
            }
            // Constructing header and relation
            return tuples
                .mapError(Query.Errors.expression)
                .mapError(Relation.Errors.query)
                .flatMap { tuples in
                    Header.create(attributes: projectedAttributes)
                        .mapError(Relation.Errors.header)
                        .map { header in (header, tuples) }
                }
                .map(Relation.init)
        }}
    }

    private func select(where predicate: BooleanExpression) -> (Relation) -> Relation.Throws<Relation> {
        return { r in r.state.flatMap { s in
            let errors = predicate.attributes.subtracting(s.header.attributes.map(\.name))
            if let errs = errors.decompose().map(OneOrMore.few) {
                return .failure(.query(.unknownAttributes(errs)))
            }
            return s.tuples.filter { predicate.executeAndCast(with: ExpressionContext(values: $0.values)) }
                .mapError(Query.Errors.expression)
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
        zip(one.state, another.state).flatMap { l, r in
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
        zip(one.state, another.state).flatMap { l, r in
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
        zip(one.state, another.state).flatMap { l, r in
            let lAttrs = l.header.attributes
            let rAttrs = r.header.attributes
            guard Set(lAttrs).isSuperset(of: rAttrs) else {
                guard let (lErrs, rErrs) = zip(lAttrs.decompose(), rAttrs.decompose()).map(OneOrMore.tupleOfFew) else {
                    return .failure(.header(.empty))
                }
                return .failure(.query(.attributesNotSupersetToAnother(lErrs, rErrs)))
            }
            let uniqueAttributes = Set(lAttrs).subtracting(rAttrs).map(\.name).map(ProjectionArgument.init)

            let ur = Query.projection(uniqueAttributes, .just(one))
            let t = Query.product(ur, .just(another))
            let u = Query.subtraction(t, .just(one))
            let v = Query.projection(uniqueAttributes, u)
            let w = Query.subtraction(ur, v)

            return w.execute()
        }
    }

    private func naturalJoin(_ one: Relation, and another: Relation) -> Relation.Throws<Relation> {
        innerJoin(one, and: another, on: nil)
    }

    private func thetaJoin(where predicate: BooleanExpression) -> (Relation, Relation) -> Relation.Throws<Relation> {
        return { one, another in
            self.innerJoin(one, and: another, on: predicate)
        }
    }

    private func innerJoin(_ one: Relation, and another: Relation, on predicate: BooleanExpression?) -> Relation.Throws<Relation> {
        zip(one.state, another.state).flatMap { l, r in
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
                        r.tuples.compactMap { rt -> Relation.Throws<Tuple?> in
                            let shouldJoin = commonAttributeNames.reduce(true) { acc, attribute in
                                acc && lt[attribute] == rt[attribute]
                            }
                            let values = lt.values.merging(rt.values, uniquingKeysWith: { orig, _ in orig })
                            let result = predicate?.executeAndCast(with: ExpressionContext(values: values)) ?? .success(true)
                            return result
                                .mapError(Query.Errors.expression)
                                .mapError(Relation.Errors.query)
                                .map { res in shouldJoin && res ? Tuple(values: values) : nil }
                        }
                    }
                    return tuples.map { Relation(header: header, tuples: $0) }
                }
        }
    }

    private func leftSemiJoin(_ one: Relation, and another: Relation) -> Relation.Throws<Relation> {
        zip(one.state, another.state).flatMap { l, r in
            let lAttrs = Set(l.header.attributes.map(\.name)).map(ProjectionArgument.init)
            return Query.projection(lAttrs, .join(.natural, .just(one), .just(another))).execute()
        }
    }

    private func rightSemiJoin(_ one: Relation, and another: Relation) -> Relation.Throws<Relation> {
        leftSemiJoin(another, and: one)
    }

    private func antiSemiJoin(_ one: Relation, and another: Relation) -> Relation.Throws<Relation> {
        zip(one.state, another.state).flatMap { l, r in
            Query.subtraction(.just(one), .join(.semi(.left), .just(one), .just(another))).execute()
        }
    }
}
