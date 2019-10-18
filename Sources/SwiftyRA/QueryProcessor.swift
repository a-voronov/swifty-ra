public final class QueryProcessor {
    public func execute(query: Query) throws -> Relation {
        switch query {
        case let .projection(attrs, q):
            return try project(attributes: attrs, r: try execute(query: q))
        case let .selection(predicate, q):
            return try select(where: predicate, r: try execute(query: q))
        case let .rename(from, to, q):
            return try rename(from: from, to: to, r: try execute(query: q))
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

    private func rename(from: AttributeName, to: AttributeName, r: Relation) throws -> Relation {
        guard r.header[from] != nil else {
            throw Errors.wrongAttribute(from)
        }
        let header = try Header(attributes: r.header.attributes.map { attribute in
            attribute.name == from
                ? Attribute(name: to, type: attribute.type)
                : attribute
        })
        let tuples = r.tuples.map { tuple -> Tuple in
            var values = tuple.values
            values[to] = values.removeValue(forKey: from) ?? Value.none
            return Tuple(values: values)
        }
        return Relation(header: header, tuples: tuples)
    }
}
