public final class QueryProcessor {
    public func execute(query: Query) throws -> Relation {
        switch query {
        case let .projection(attrs, q):
            return try project(attributes: attrs, r: try execute(query: q))
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
}
