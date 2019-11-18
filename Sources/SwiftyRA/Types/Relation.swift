// MARK: Relation

/// Stores header with attributes in the given order, which serves as a relation scheme.
/// Stores tuples with values.
/// Can be either in sucess or failure state. Can't restore from the failure state. Can fail from the success state.
/// Allows performing Relational Algebra lazily. Actual query will be executed when accessing `state` or `header` or `tuples` values.
@dynamicMemberLookup
public struct Relation {
    public struct State: Hashable {
        public let (header, tuples): (Header, Tuples)

        init(header: Header, tuples: Tuples) {
            (self.header, self.tuples) = (header, tuples)
        }
    }

    private enum InnerState: Hashable {
        case resolved(Header, Tuples)
        case unresolved(Query)

        var query: Query? {
            guard case let .unresolved(q) = self else { return nil }
            return q
        }
    }

    private let innerState: Reference<Throws<InnerState>>

    public var state: Throws<State> {
        innerState.value.flatMap { s in
            switch s {
            case let .resolved(h, ts):
                return .success(State(header: h, tuples: ts))
            case let .unresolved(q):
                innerState.value = q.optimize().execute().flatMap(\.innerState.value)

                return state
            }
        }
    }

    public var header: Throws<Header> {
        state.map(\.header)
    }

    public var tuples: Throws<Tuples> {
        state.map(\.tuples)
    }

    // TODO: not yet sure if it's a good idea, but definitely looks nice with expressions :)
    public subscript(dynamicMember member: AttributeName) -> MemberExpression {
        atr(member)
    }

    /// Preserves header attributes order.
    /// Duplicated attributes will cause error.
    /// Values' order in Tuple should correspond to Header Attributes order, otherwise Tuple will be treated as invalid.
    /// Invalid Tuples will be just ignored and not added into Relation (make this behvaior configuarble to result in error?).
    public init(header: KeyValuePairs<AttributeName, AttributeType>, tuples: [[Value]]) {
        innerState = Reference(Header.create(header)
            .mapError(Errors.header)
            .map { header in .resolved(header, Tuples(header: header, tuples: tuples)) }
        )
    }

    public init(header: KeyValuePairs<AttributeName, AttributeType>, tuples: [[AttributeName: Value]]) {
        innerState = Reference(Header.create(header)
            .mapError(Errors.header)
            .map { header in .resolved(header, Tuples(header: header, tuples: tuples)) }
        )
    }

    init(header: Header, tuples: Tuples) {
        innerState = Reference(.success(.resolved(header, tuples)))
    }

    init(query: Query) {
        innerState = Reference(.success(.unresolved(query)))
    }
}

// MARK: Algebra

// TODO: Should be extracted into Algebra folder once lazy evaluation is implemented
public extension Relation {
    private func withUnaryQuery(_ transform: (Query) -> Query) -> Relation {
        innerState.value.map(\.query)
            .map { q in Relation(query: transform(q ?? .just(self))) }
            .value ?? self
    }

    private func withBinaryQuery(another: Relation, transform: (Query, Query) -> Query) -> Relation {
        switch (innerState.value, another.innerState.value) {
        case let (.success(l), .success(r)):
            return Relation(query: transform(l.query ?? .just(self), r.query ?? .just(another)))
        case (.failure, _):
            return self
        case (_, .failure):
            return another
        }
    }

    @available(*, deprecated, renamed: "project(_:)")
    func project(attributes: Set<AttributeName>) -> Relation {
        withUnaryQuery { q in .projection(attributes, q) }
    }

    func project(_ arguments: Query.ProjectionArgument...) -> Relation {
        withUnaryQuery { q in .project(arguments, q) }
    }

    func select(where predicate: BooleanExpression) -> Relation {
        withUnaryQuery { q in .selection(predicate, q) }
    }

    func rename(to newAttribute: AttributeName, from originalAttribute: AttributeName) -> Relation {
        withUnaryQuery { q in .rename(newAttribute, originalAttribute, q) }
    }

    func order(by attributes: KeyValuePairs<AttributeName, Query.SortingOrder>) -> Relation {
        withUnaryQuery { q in .orderBy(attributes.map(Pair.init), q) }
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

    func join(with another: Relation, on predicate: BooleanExpression? = nil) -> Relation {
        withBinaryQuery(another: another) { lq, rq in .join(predicate.map(Query.Join.theta) ?? .natural, lq, rq) }
    }

    func leftSemiJoin(with another: Relation) -> Relation {
        withBinaryQuery(another: another) { lq, rq in .join(.semi(.left), lq, rq) }
    }

    func rightSemiJoin(with another: Relation) -> Relation {
        withBinaryQuery(another: another) { lq, rq in .join(.semi(.right), lq, rq) }
    }

    func antiSemiJoin(with another: Relation) -> Relation {
        withBinaryQuery(another: another) { lq, rq in .join(.semi(.anti), lq, rq) }
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

// MARK: Equality & Hashing

extension Relation: Equatable {
    public static func == (lhs: Relation, rhs: Relation) -> Bool {
        lhs.state == rhs.state
    }
}

extension Relation: Hashable {
    public func hash(into hasher: inout Hasher) {
        state.hash(into: &hasher)
    }
}
