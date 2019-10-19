public final class QueryProcessor {
    public func execute(query: Query) throws -> Relation {
        switch query {
        case let .projection(attrs, q):
            return try project(attributes: attrs, r: try execute(query: q))
        case let .selection(predicate, q):
            return try select(where: predicate, r: try execute(query: q))
        case let .rename(to, from, q):
            return try rename(to: to, from: from, r: try execute(query: q))
        case let .orderBy(attrs, q):
            return try orderBy(attributes: attrs, r: try execute(query: q))
        case let .relation(r):
            return r
        }
    }

    private func project(attributes: Set<AttributeName>, r: Relation) throws -> Relation {
        let header = try Header(attributes: try attributes.map { attributeName in
            guard let attribute = r.header[attributeName] else {
                throw Errors.wrongAttribute(attributeName)
            }
            return attribute
        })
        let tuples = r.tuples.map { tuple in
            Tuple(values: attributes.reduce(into: [:]) { (acc, attributeName) in
                acc[attributeName] = tuple[attributeName] ?? Value.none
            })
        }
        return Relation(header: header, tuples: tuples)
    }

    private func select(where predicate: (Tuple) -> Bool, r: Relation) throws -> Relation {
        return Relation(header: r.header, tuples: r.tuples.filter(predicate))
    }

    private func rename(to: AttributeName, from: AttributeName, r: Relation) throws -> Relation {
        guard r.header[from] != nil else {
            throw Errors.wrongAttribute(from)
        }
        guard r.header[to] == nil else {
            throw Errors.duplicatedAttribute(to)
        }
        let header = try Header(attributes: r.header.attributes.map { attribute in
            attribute.name == from
                ? Attribute(name: to, type: attribute.type)
                : attribute
        })
        // TODO: can be paralleled for big amount of tuples with DispatchGroup (if there's such in swift-corelibs)
        let tuples = r.tuples.map { tuple -> Tuple in
            var values = tuple.values
            values[to] = values.removeValue(forKey: from) ?? Value.none
            return Tuple(values: values)
        }
        return Relation(header: header, tuples: tuples)
    }

    private func orderBy(attributes: [(attribute: AttributeName, order: Query.Order)], r: Relation) throws -> Relation {
        let unknownAttributes = Set(attributes.map(\.attribute)).subtracting(r.header.attributes.map(\.name))
        guard unknownAttributes.isEmpty else {
            throw Errors.wrongAttributes(unknownAttributes)
        }
        let tuples = try r.tuples.sorted { lhs, rhs in
            for (attribute, order) in attributes {
                let l = lhs[attribute] ?? Value.none
                let r = rhs[attribute] ?? Value.none

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
        return Relation(header: r.header, tuples: tuples)
    }
}
