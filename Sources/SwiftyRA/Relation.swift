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
                return .success(State(h, ts))
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

    // TODO: add intiializer with tuples with named values?

    /// Preserves header attributes order.
    /// Duplicated attributes will cause error.
    /// Values' order in Tuple should correspond to Header Attributes order, otherwise Tuple will be treated as invalid.
    /// Invalid Tuples will be just ignored and not added into Relation (make this behvaior configuarble to result in error?).
    public init(header: KeyValuePairs<AttributeName, AttributeType>, tuples: [[Value]]) {
        innerState = Reference(Header.create(header).mapError(Relation.Errors.header).flatMap { header in
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
        })
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
            .map { q in
                Relation(query: transform(q ?? .relation(self)))
            }
            .value ?? self
    }

    // TODO: in case of error in any relation, might it be better to return new relation with that error instead of current one?
    private func withBinaryQuery(another: Relation, transform: (Query, Query) -> Query) -> Relation {
        zip(innerState.value.map(\.query), another.innerState.value.map(\.query))
            .mapError(\.value)
            .map { q, anotherQ in
                Relation(query: transform(q ?? .relation(self), anotherQ ?? .relation(another)))
            }
            .value ?? self
    }

    func project(attributes: Set<AttributeName>) -> Relation {
        withUnaryQuery { q in .projection(attributes, q) }
    }

    func select(from attributes: Set<AttributeName>, where predicate: @escaping (Query.SelectionContext) throws -> Bool) -> Relation {
        withUnaryQuery { q in .selection(attributes, predicate, q) }
    }

    func rename(to newAttribute: AttributeName, from originalAttribute: AttributeName) -> Relation {
        withUnaryQuery { q in .rename(newAttribute, originalAttribute, q) }
    }

    func order(by attributes: KeyValuePairs<AttributeName, Query.SortingOrder>) -> Relation {
        withUnaryQuery { q in .orderBy(attributes, q) }
    }

    func intersect(with another: Relation) -> Relation {
        withBinaryQuery(another: another) { lq, rq in .intersection(lq, rq) }
    }

    func union(with another: Relation) -> Relation {
        withBinaryQuery(another: another) { lq, rq in .union(lq, rq) }
    }

    func subtract(from another: Relation) -> Relation {
        withBinaryQuery(another: another) { lq, rq in .subtraction(lq, rq) }
    }

    func product(with another: Relation) -> Relation {
        withBinaryQuery(another: another) { lq, rq in .product(lq, rq) }
    }

    func divide(by another: Relation) -> Relation {
        withBinaryQuery(another: another) { lq, rq in .division(lq, rq) }
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

