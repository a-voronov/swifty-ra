// MARK: - Passive Relation

//public struct Relation {
//    public let header: Header
//    public let tuples: Tuples
//
//    public init(header: KeyValuePairs<AttributeName, AttributeType>, tuples: [[Value]]) throws {
//        guard !header.isEmpty else {
//            throw Errors.emptyHeader
//        }
//        let header = try Header(header)
//        self.header = header
//        self.tuples = tuples.compactMap { tuple -> Tuple? in
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
//    }
//
//    init(header: Header, tuples: Tuples) {
//        self.header = header
//        self.tuples = tuples
//    }
//}

// MARK: - Active Relation

/// Stores header with attributes in the given order, which serves as a relation scheme.
/// Stores tuples with values.
/// Can be either in sucess or failure state. Can't restore from the failure state. Can fail from the success state.
/// Allows performing Relational Algebra lazily. Actual query will be executed when accessing `state` or `header` or `tuples` values.
public struct Relation {
    public enum Errors: Error {
        case header(Header.Errors)
        case value(Value.Errors)
        case query(Query.Errors)
        case unknown(Error)
    }

    public typealias State = (header: Header, tuples: Tuples)

    private enum InnerState {
        case resolved(Header, Tuples)
        case unresolved(Query)
    }

    private var innerState: Result<InnerState, Errors>

    public var state: Result<State, Errors> {
        innerState.flatMap { s in
            switch s {
            case let .resolved(h, ts):
                return .success(State(h, ts))
            case let .unresolved(q):
//                innerState = ...
                return q.execute().flatMap(\.state)
            }
        }
    }

    public var header: Result<Header, Errors> {
        state.map(\.header)
    }

    public var tuples: Result<Tuples, Errors> {
        state.map(\.tuples)
    }

    /// Preserves header attributes order.
    /// Duplicated attributes will cause error.
    /// Values' order in Tuple should correspond to Header Attributes order, otherwise Tuple will be treated as invalid.
    /// Invalid Tuples will be just ignored and not added into Relation (make this behvaior configuarble to result in error?).
    public init(header: KeyValuePairs<AttributeName, AttributeType>, tuples: [[Value]]) {
        innerState = Header.create(header).mapError(Relation.Errors.header).flatMap { header in
            let tuples = tuples.compactMap { tuple -> Tuple? in
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
            return .success(.resolved(header, tuples))
        }
    }

    init(header: Header, tuples: Tuples) {
        innerState = .success(.resolved(header, tuples))
    }
}

//public struct Relation {
//    private enum State {
//        case resolved(Header, Tuples)
//        case unresolved(Header, Tuples, Query)
//    }
//
////    private var state: Reference<State>
//    private var query: Query? = nil
//
//    public let header: Header
//    public let tuples: Tuples
//
//    public init(header: KeyValuePairs<AttributeName, AttributeType>, tuples: [[Value]]) throws {
//        guard !header.isEmpty else {
//            throw Errors.emptyHeader
//        }
//        let header = try Header(header)
//        self.header = header
//        self.tuples = tuples.compactMap { tuple -> Tuple? in
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
////        state = Reference(.resolved(self.header, self.tuples))
//    }
//
//    init(header: Header, tuples: Tuples) {
//        self.header = header
//        self.tuples = tuples
//
////        state = Reference(.resolved(self.header, self.tuples))
//    }
//}

//extension Relation {
////    private func update(query: Query, relation: inout Relation) -> Relation {
////        var r = relation
////        r.query = query
////        return r
////    }
//
////    private func updated(relation: (inout Relation) -> Void) -> Relation {
////        var r = self
////        relation(&r)
////        return r
////    }
//
////    private var query: Query {
////        get {
////            switch state.value {
////            case .resolved: return .relation(self)
////            case .unresolved(_, _, let q): return q
////            }
////        }
////    }
////
////    private func set(query: Query) -> Relation {
////        switch state.value {
////        case let .resolved(h, ts): state.value = .unresolved(h, ts, query)
////        case let .unresolved(h, ts, _): state.value = .unresolved(h, ts, query)
////        }
////        return self
////    }
////
//    func project(attributes: Set<AttributeName>) -> Relation {
//        updating(self) { r in r.query = .projection(attributes, r.query ?? .relation(r)) }
//    }
//
//    func select(from attributes: Set<AttributeName>, where predicate: @escaping (Query.Context) throws -> Bool) -> Relation {
//        updating(self) { r in r.query = .selection(attributes, predicate, r.query ?? .relation(r)) }
//    }
//
////    var select: Selection {
////        Selection(relation: self)
////    }
//
//    func resolve() throws -> Relation {
//        try query.map(QueryProcessor().execute) ?? self
//    }
//}

//@dynamicCallable
//public struct Selection {
//    public enum Operation {
//        public enum Members {
//            case attr(AttributeName)
//            case value(Value)
//        }
//
//        case eq(Members)
//        case neq(Members)
//        case gt(Members)
//        case lt(Members)
//        case ge(Members)
//        case le(Members)
//    }
//
//    fileprivate let relation: Relation
//
//    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<AttributeName, Value>) -> Relation {
//        call(with: args.map { key, value in (key, .eq(.value(value))) })
//    }
//
//    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<AttributeName, Operation>) -> Relation {
//        call(with: Array(args))
//    }
//
//    private func call(with args: [(key: AttributeName, value: Operation)]) -> Relation {
//        let attributes = Set(args.map(\.key).filter(\.isNotEmpty))
//        let values: [AttributeName: Operation] = args.reduce(into: [:]) { acc, pair in
//            guard pair.key.isNotEmpty else {
//                return
//            }
//            acc[pair.key] = pair.value
//        }
//        return relation.select(
//            from: attributes,
//            where: { ctx in
//                attributes.reduce(into: true) { acc, attribute in
//                    // TODO: resolve Operation
////                    acc = acc && ctx[attribute] == values[attribute]
//                }
//            }
//        )
//    }
//}

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
