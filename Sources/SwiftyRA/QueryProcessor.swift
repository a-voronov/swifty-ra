public extension Query {
    enum Errors: Error {
        case wrongAttributes(Set<AttributeName>)
    }

    func execute() -> Result<Relation, Relation.Errors> {
        switch self {
        case let .projection(attrs, q):           return q.execute().flatMap(project(attributes: attrs))
        case let .selection(attrs, predicate, q): return q.execute().flatMap(select(from: attrs, where: predicate))
        case let .rename(to, from, q):            return q.execute().flatMap(rename(to: to, from: from))
        case let .orderBy(attrs, q):              return q.execute().flatMap(orderBy(attributes: attrs))
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
                return .failure(.query(.wrongAttributes(errors)))
            }

            return Header.create(attributes: projectedAttributes).mapError(Relation.Errors.header).map { header in
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
        where predicate: @escaping (Query.SelectionContext) throws -> Bool
    ) -> (Relation) -> Result<Relation, Relation.Errors> {
        return { r in r.state.flatMap { s in
            var errors: Set<AttributeName> = []

            for attribute in attributes {
                if s.header[attribute] == nil {
                    errors.insert(attribute)
                }
            }

            guard errors.isEmpty else {
                return .failure(.query(.wrongAttributes(errors)))
            }

            do {
                let tuples = try s.tuples.filter { tuple in
                    try predicate(Query.SelectionContext(values: tuple.values.filter { pair in
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
                return .failure(.query(.wrongAttributes([original])))
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
                return .failure(.query(.wrongAttributes(unknownAttributes)))
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
                        case .desc: return try r < l
                        }
                    }
                    return false
                }
                return Relation(header: s.header, tuples: tuples)
            }
            .mapError { .value($0 as! Value.Errors) }
        }}
    }
}

//public final class QueryProcessor {
//    // TODO: optimize recursion to iterative process
//    public func execute(query: Query) throws -> Relation {
//        switch query {
//        case let .projection(attrs, q):
//            return try project(attributes: attrs, r: try execute(query: q))
//        case let .selection(attrs, predicate, q):
//            return try select(from: attrs, where: predicate, r: try execute(query: q))
//        case let .rename(to, from, q):
//            return try rename(to: to, from: from, r: try execute(query: q))
//        case let .orderBy(attrs, q):
//            return try orderBy(attributes: attrs, r: try execute(query: q))
//        case let .relation(r):
//            return r
//        }
//    }
//
//    private func project(attributes: Set<AttributeName>, r: Relation) throws -> Relation {
//        let header = try Header(attributes: try attributes.map { attributeName in
//            guard let attribute = r.header[attributeName] else {
//                throw Errors.wrongAttributes([attributeName])
//            }
//            return attribute
//        })
//        let tuples = r.tuples.map { tuple in
//            Tuple(values: attributes.reduce(into: [:]) { (acc, attributeName) in
//                acc[attributeName] = tuple[attributeName, default: .none]
//            })
//        }
//        return Relation(header: header, tuples: tuples)
//    }
//
//    private func select(from attributes: Set<AttributeName>, where predicate: (Query.Context) throws -> Bool, r: Relation) throws -> Relation {
//        for attribute in attributes {
//            if r.header[attribute] == nil {
//                throw Errors.wrongAttributes([attribute])
//            }
//        }
//        let tuples = try r.tuples.filter { tuple in
//            try predicate(Query.Context(values: tuple.values.filter { pair in
//                attributes.contains(pair.key)
//            }))
//        }
//        return Relation(header: r.header, tuples: tuples)
//    }
//
//    private func rename(to: AttributeName, from: AttributeName, r: Relation) throws -> Relation {
//        guard r.header[from] != nil else {
//            throw Errors.wrongAttributes([from])
//        }
////        guard r.header[to] == nil else {
////            throw Errors.duplicatedAttribute(to)
////        }
//        let header = try Header(attributes: r.header.attributes.map { attribute in
//            attribute.name == from
//                ? Attribute(name: to, type: attribute.type)
//                : attribute
//        })
//        // TODO: can be paralleled for big amount of tuples with DispatchGroup (if there's such in swift-corelibs)
//        let tuples = r.tuples.map { tuple -> Tuple in
//            var values = tuple.values
//            values[to] = values.removeValue(forKey: from) ?? Value.none
//            return Tuple(values: values)
//        }
//        return Relation(header: header, tuples: tuples)
//    }
//
//    private func orderBy(attributes: KeyValuePairs<AttributeName, Query.Order>, r: Relation) throws -> Relation {
//        let unknownAttributes = Set(attributes.map(\.key)).subtracting(r.header.attributes.map(\.name))
//        guard unknownAttributes.isEmpty else {
//            throw Errors.wrongAttributes(unknownAttributes)
//        }
//        let tuples = try r.tuples.sorted { lhs, rhs in
//            for (attribute, order) in attributes {
//                let l = lhs[attribute, default: .none]
//                let r = rhs[attribute, default: .none]
//
//                guard l != r else {
//                    continue
//                }
//
//                switch order {
//                case .asc:  return try l < r
//                case .desc: return try r < l
//                }
//            }
//            return false
//        }
//        return Relation(header: r.header, tuples: tuples)
//    }
//}
