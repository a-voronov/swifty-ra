public extension Query {
    // TODO: add info about failed operation with path to it?
    // TODO: should run optimization on each execution step?
    enum Errors: Error, Equatable {
        /// no such attributes
        case unknownAttributes(Set<AttributeName>)
        /// same name, different types
        case incompatibleAttributes([Pair<Attribute, Attribute>])
        /// should be equal
        case attributesNotUnionCompatible([Attribute], [Attribute])
        /// should not share common attributes
        case attributesNotDisjointed([Attribute], [Attribute])
        /// should contain all attributes from another relation
        case attributesNotSupersetToAnother([Attribute], [Attribute])
    }

    func execute() -> Result<Relation, Relation.Errors> {
        switch self {
        case let .projection(attrs, q):           return q.execute().flatMap(project(attributes: attrs))
        case let .selection(attrs, predicate, q): return q.execute().flatMap(select(from: attrs, where: predicate))
        case let .rename(to, from, q):            return q.execute().flatMap(rename(to: to, from: from))
        case let .orderBy(attrs, q):              return q.execute().flatMap(orderBy(attributes: attrs))
        case let .intersection(lhs, rhs):         return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(intersect)
        case let .union(lhs, rhs):                return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(union)
        case let .subtraction(lhs, rhs):          return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(subtract)
        case let .product(lhs, rhs):              return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(product)
        case let .division(lhs, rhs):             return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(divide)
        case let .join(.natural, lhs, rhs):       return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(naturalJoin)
        case let .join(.theta(pred), lhs, rhs):   return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(thetaJoin(where: pred))
        case let .join(.leftOuter, lhs, rhs):     return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(leftOuterJoin)
        case let .join(.rightOuter, lhs, rhs):    return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(rightOuterJoin)
        case let .join(.fullOuter, lhs, rhs):     return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(fullOuterJoin)
        case let .join(.leftSemi, lhs, rhs):      return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(leftSemiJoin)
        case let .join(.rightSemi, lhs, rhs):     return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(rightSemiJoin)
        case let .join(.antiSemi, lhs, rhs):      return zip(lhs.execute(), rhs.execute()).mapError(\.value).flatMap(antiSemiJoin)
        case let .relation(r):                    return .success(r)
        }
    }

    private func project(attributes: Set<AttributeName>) -> (Relation) -> Result<Relation, Relation.Errors> {
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
            guard errors.isEmpty else {
                return .failure(.query(.unknownAttributes(errors)))
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

    private func select(
        from attributes: Set<AttributeName>,
        where predicate: @escaping (Query.PredicateContext) throws -> Bool
    ) -> (Relation) -> Result<Relation, Relation.Errors> {
        return { r in r.state.flatMap { s in
            var errors: Set<AttributeName> = []

            for attribute in attributes {
                if s.header[attribute] == nil {
                    errors.insert(attribute)
                }
            }
            guard errors.isEmpty else {
                return .failure(.query(.unknownAttributes(errors)))
            }
            do {
                let tuples = try s.tuples.filter { tuple in
                    try predicate(Query.PredicateContext(values: tuple.values.filter { pair in
                        attributes.contains(pair.key)
                    }))
                }
                return .success(Relation(header: s.header, tuples: tuples))
            } catch let error as Value.Errors {
                return .failure(.value(error))
            } catch let error as Query.Errors {
                return .failure(.query(error))
            } catch let error as Header.Errors {
                return .failure(.header(error))
            } catch let error as Relation.Errors {
                return .failure(error)
            } catch {
                return .failure(.unknown(error))
            }
        }}
    }

    private func rename(to new: AttributeName, from original: AttributeName) -> (Relation) -> Result<Relation, Relation.Errors> {
        return { r in r.state.flatMap { s in
            guard let originalAttr = s.header[original], let originalIndex = s.header.attributes.firstIndex(of: originalAttr) else {
                return .failure(.query(.unknownAttributes([original])))
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

    private func orderBy(attributes: KeyValuePairs<AttributeName, Query.SortingOrder>) -> (Relation) -> Result<Relation, Relation.Errors> {
        return { r in r.state.flatMap { s in
            let unknownAttributes = Set(attributes.map(\.key)).subtracting(s.header.attributes.map(\.name))
            guard unknownAttributes.isEmpty else {
                return .failure(.query(.unknownAttributes(unknownAttributes)))
            }
            return Result {
                let tuples = try s.tuples.sorted { lhs, rhs in
                    for (attribute, order) in attributes {
                        let l = lhs[attribute, default: .none]
                        let r = rhs[attribute, default: .none]

                        guard l != r else {
                            continue
                        }

                        switch order {
                        case .asc:  return try l < r
                        case .desc: return try l > r
                        }
                    }
                    return false
                }
                return Relation(header: s.header, tuples: tuples)
            }
            .mapError { .value($0 as! Value.Errors) }
        }}
    }

    private func intersect(_ one: Relation, with another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            guard l.header == r.header else {
                return .failure(.query(.attributesNotUnionCompatible(l.header.attributes, r.header.attributes)))
            }
            let tuples = l.tuples.intersection(r.tuples)
            return .success(Relation(header: l.header, tuples: tuples))
        }
    }

    private func union(_ one: Relation, with another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            guard l.header == r.header else {
                return .failure(.query(.attributesNotUnionCompatible(l.header.attributes, r.header.attributes)))
            }
            let tuples = l.tuples.union(r.tuples)
            return .success(Relation(header: l.header, tuples: tuples))
        }
    }

    private func subtract(_ one: Relation, and another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            guard l.header == r.header else {
                return .failure(.query(.attributesNotUnionCompatible(l.header.attributes, r.header.attributes)))
            }
            let tuples = l.tuples.subtracting(r.tuples)
            return .success(Relation(header: l.header, tuples: tuples))
        }
    }

    private func product(_ one: Relation, with another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            let lAttrs = l.header.attributes
            let rAttrs = r.header.attributes
            guard Set(lAttrs).isDisjoint(with: rAttrs) else {
                return .failure(.query(.attributesNotDisjointed(lAttrs, rAttrs)))
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

    private func divide(_ one: Relation, by another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            let lAttrs = l.header.attributes
            let rAttrs = r.header.attributes
            guard Set(lAttrs).isSuperset(of: rAttrs) else {
                return .failure(.query(.attributesNotSupersetToAnother(lAttrs, rAttrs)))
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

    private func naturalJoin(_ one: Relation, and another: Relation) -> Result<Relation, Relation.Errors> {
        innerJoin(one, and: another, on: nil)
    }

    private func thetaJoin(where predicate: @escaping (Query.PredicateContext) throws -> Bool) -> (Relation, Relation) -> Result<Relation, Relation.Errors> {
        return { one, another in
            self.innerJoin(one, and: another, on: predicate)
        }
    }

    private func innerJoin(_ one: Relation, and another: Relation, on predicate: ((Query.PredicateContext) throws -> Bool)?) -> Result<Relation, Relation.Errors> {
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
                    return .failure(.query(.unknownAttributes([attributeName])))
                }
            }
            guard errors.isEmpty else {
                return .failure(.query(.incompatibleAttributes(errors)))
            }
            return Header.create(attributes: attributes)
                .mapError(Relation.Errors.header)
                .flatMap { header in
                    do {
                        let commonAttributeNames = Set(lAttrs).intersection(rAttrs)
                        let tuples = try l.tuples.flatMap { lt in
                            try r.tuples.compactMap { rt in
                                let shouldJoin = commonAttributeNames.reduce(true) { acc, attribute in
                                    acc && lt[attribute] == rt[attribute]
                                }
                                let values = lt.values.merging(rt.values, uniquingKeysWith: { orig, _ in orig })
                                let result = try predicate?(Query.PredicateContext(values: values)) ?? true
                                return shouldJoin && result
                                    ? Tuple(values: values)
                                    : nil
                            }
                        }
                        return .success(Relation(header: header, tuples: tuples))
                    } catch let error as Value.Errors {
                        return .failure(.value(error))
                    } catch let error as Query.Errors {
                        return .failure(.query(error))
                    } catch let error as Header.Errors {
                        return .failure(.header(error))
                    } catch let error as Relation.Errors {
                        return .failure(error)
                    } catch {
                        return .failure(.unknown(error))
                    }
                }
        }
    }

    private func leftOuterJoin(_ one: Relation, and another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            // TODO: implement me!
            return .success(one)
        }
    }

    private func rightOuterJoin(_ one: Relation, and another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            // TODO: implement me!
            return .success(one)
        }
    }

    private func fullOuterJoin(_ one: Relation, and another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            // TODO: implement me!
            return .success(one)
        }
    }

    private func leftSemiJoin(_ one: Relation, and another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            // TODO: implement me!
            return .success(one)
        }
    }

    private func rightSemiJoin(_ one: Relation, and another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            // TODO: implement me!
            return .success(one)
        }
    }

    private func antiSemiJoin(_ one: Relation, and another: Relation) -> Result<Relation, Relation.Errors> {
        zip(one.state, another.state).mapError(\.value).flatMap { l, r in
            // TODO: implement me!
            return .success(one)
        }
    }
}

