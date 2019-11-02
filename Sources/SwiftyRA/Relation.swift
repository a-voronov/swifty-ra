/// Stores header with attributes in the given order, which serves as a relation scheme.
/// Stores tuples with values.
/// Can be either in sucess or failure state. Can't restore from the failure state. Can fail from the success state.
/// Allows performing Relational Algebra lazily. Actual query will be executed when accessing `state` or `header` or `tuples` values.
@dynamicMemberLookup
public struct Relation {
    public enum Errors: Error {
        case header(Header.Errors)
        case value(Value.Errors)
        case query(Query.Errors)
        case unknown(Error)
    }

    public struct State: Equatable {
        public let (header, tuples): (Header, Tuples)

        init(header: Header, tuples: Tuples) {
            (self.header, self.tuples) = (header, tuples)
        }
    }

    private enum InnerState {
        case resolved(Header, Tuples)
        case unresolved(Query)

        var query: Query? {
            guard case let .unresolved(q) = self else { return nil }
            return q
        }
    }

    private let innerState: Reference<Result<InnerState, Errors>>

    public var state: Result<State, Errors> {
        innerState.value.flatMap { s in
            switch s {
            case let .resolved(h, ts):
                return .success(State(header: h, tuples: ts))
            case let .unresolved(q):
                self.innerState.value = q.optimize().execute().flatMap(\.innerState.value)

                return self.state
            }
        }
    }

    public var header: Result<Header, Errors> {
        state.map(\.header)
    }

    public var tuples: Result<Tuples, Errors> {
        state.map(\.tuples)
    }

    // TODO: not yet sure if it's a good idea, but definitely looks nice with predicate :)
    public subscript(dynamicMember member: AttributeName) -> Query.Predicate.Member {
        atr(member)
    }

    // TODO: add intiializer with tuples with named values?

    /// Preserves header attributes order.
    /// Duplicated attributes will cause error.
    /// Values' order in Tuple should correspond to Header Attributes order, otherwise Tuple will be treated as invalid.
    /// Invalid Tuples will be just ignored and not added into Relation (make this behvaior configuarble to result in error?).
    public init(header: KeyValuePairs<AttributeName, AttributeType>, tuples: [[Value]]) {
        innerState = Reference(Header.create(header)
            .mapError(Relation.Errors.header)
            .map { header in .resolved(header, Tuples(attributes: header.attributes, tuples: tuples)) }
        )
    }

    init(header: Header, tuples: Tuples) {
        innerState = Reference(.success(.resolved(header, tuples)))
    }

    init(query: Query) {
        innerState = Reference(.success(.unresolved(query)))
    }
}

public extension Relation {
    private func withUnaryQuery(_ transform: (Query) -> Query) -> Relation {
        innerState.value.map(\.query)
            .map { q in Relation(query: transform(q ?? .relation(self))) }
            .value ?? self
    }

    private func withBinaryQuery(another: Relation, transform: (Query, Query) -> Query) -> Relation {
        switch (innerState.value, another.innerState.value) {
        case let (.success(l), .success(r)):
            return Relation(query: transform(l.query ?? .relation(self), r.query ?? .relation(another)))
        case (.failure, _):
            return self
        case (_, .failure):
            return another
        }
    }

    func project(attributes: Set<AttributeName>) -> Relation {
        withUnaryQuery { q in .projection(attributes, q) }
    }

    func select(where predicate: Query.Predicate) -> Relation {
        withUnaryQuery { q in .selection(predicate, q) }
    }

    func rename(to newAttribute: AttributeName, from originalAttribute: AttributeName) -> Relation {
        withUnaryQuery { q in .rename(newAttribute, originalAttribute, q) }
    }

    func order(by attributes: KeyValuePairs<AttributeName, Query.SortingOrder>) -> Relation {
        withUnaryQuery { q in .orderBy(attributes, q) }
    }

    func intersect(with another: Relation) -> Relation {
        withBinaryQuery(another: another, transform: Query.intersection)
    }

    func union(with another: Relation) -> Relation {
        withBinaryQuery(another: another, transform: Query.union)
    }

    func subtract(_ another: Relation) -> Relation {
        withBinaryQuery(another: another, transform: Query.subtraction)
    }

    func product(with another: Relation) -> Relation {
        withBinaryQuery(another: another, transform: Query.product)
    }

    func divide(by another: Relation) -> Relation {
        withBinaryQuery(another: another, transform: Query.division)
    }

    func join(with another: Relation, where predicate: Query.Predicate? = nil) -> Relation {
        withBinaryQuery(another: another) { lq, rq in .join(predicate.map(Query.Join.theta) ?? .natural, lq, rq) }
    }
}

public extension Relation {
    var select: Selection {
        Selection(relation: self)
    }

    var order: Ordering {
        Ordering(relation: self)
    }
}

// MARK: - Equatable

extension Relation.Errors: Equatable {
    public static func == (lhs: Relation.Errors, rhs: Relation.Errors) -> Bool {
        switch (lhs, rhs) {
        case let (.header(l), .header(r)): return l == r
        case let (.value(l), .value(r)): return l == r
        case let (.query(l), .query(r)): return l == r
        case let (.unknown(l), .unknown(r)): return "\(l)" == "\(r)"
        default: return false
        }
    }
}

extension Relation: Equatable {
    public static func == (lhs: Relation, rhs: Relation) -> Bool {
        lhs.state == rhs.state
    }
}
