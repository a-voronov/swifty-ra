// MARK: - Passive Relation

public struct Relation {
    public let header: Header
    public let tuples: Tuples

    public init(header: KeyValuePairs<AttributeName, AttributeType>, tuples: [[Value]]) throws {
        guard !header.isEmpty else {
            throw Errors.emptyHeader
        }
        let header = try Header(header)
        self.header = header
        self.tuples = tuples.compactMap { tuple -> Tuple? in
            var valuesPerName: [AttributeName: Value] = [:]
            for (index, attribute) in header.attributes.enumerated() {
                let value = index < tuple.count ? tuple[index] : nil
                if value.isMatching(type: attribute.type) {
                    valuesPerName[attribute.name] = value
                } else {
                    return nil
                }
            }
            return Tuple(values: valuesPerName)
        }
    }

    init(header: Header, tuples: Tuples) {
        self.header = header
        self.tuples = tuples
    }
}

// MARK: - Active Relation

//public struct Relation {
//    private enum State {
//        case resolved(Header, Tuples)
//        case unresolved(Header, Tuples, Query)
//    }
//
//    public var header: Header { resolvingState().header }
//    public var tuples: Tuples { resolvingState().tuples }
//
//    private var state: Reference<State>
//
//    private var query: Query? {
//        guard case let .unresolved(_, _, q) = state.value else { return nil }
//        return q
//    }
//
//    public init(header: [(name: AttributeName, type: AttributeType)], tuples: [[Value]]) throws {
//        guard !header.isEmpty else {
//            throw Errors.emptyHeader
//        }
//        let header = try Header(header)
//        let tuples = tuples.compactMap { tuple -> Tuple? in
//            var valuesPerName: [AttributeName: Value] = [:]
//            for (index, attribute) in header.attributes.enumerated() {
//                let value = index < tuple.count ? tuple[index] : nil
//                if value.isMatching(type: attribute.type) {
//                    valuesPerName[attribute.name] = value
//                } else {
//                    return nil
//                }
//            }
//            return Tuple(values: valuesPerName)
//        }
//        state = Reference(.resolved(header, tuples))
//    }
//
//    init(header: Header, tuples: Tuples, query: Query? = nil) {
//        if let query = query {
//            state = Reference(.unresolved(header, tuples, query))
//        } else {
//            state = Reference(.resolved(header, tuples))
//        }
//    }
//
//    private func resolvingState() -> (header: Header, tuples: Tuples) {
//        switch state.value {
//        case let .resolved(h, ts):
//            return (h, ts)
//        case let .unresolved(h, ts, q):
//            let (newH, newTs) = resolve(query: q,  with: (header, tuples))
//            state.value = .resolved(newH, newTs)
//            return (newH, newTs)
//        }
//    }
//
//    private func resolve(query: Query, with relation: (header: Header, tuples: Tuples)) -> (header: Header, tuples: Tuples) {
//        // query optimizer -> query processor
//        return (relation.header, relation.tuples)
//    }
//}
//
//public extension Relation {
//     func project(_ attributes: [AttributeName]) -> Relation {
//         Relation(header: header, tuples: tuples, query: .projection(attributes, query ?? .relation(self)))
//     }
//}
