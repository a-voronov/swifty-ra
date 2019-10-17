public struct Relation {
    private enum State {
        case resolved(Header, Tuples)
        case unresolved(Header, Tuples, Expression)
    }

    public var header: Header { resolvingState().header }
    public var tuples: Tuples { resolvingState().tuples }

    private var state: Reference<State>

    private var expression: Expression? {
        guard case let .unresolved(_, _, e) = state.value else { return nil }
        return e
    }

    public init(header: [(name: AttributeName, type: AttributeType)], tuples: [[Value]]) throws {
        guard !header.isEmpty else {
            throw Errors.emptyHeader
        }
        let header = try Header(header)
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
        state = Reference(.resolved(header, tuples))
    }

    private init(header: Header, tuples: Tuples, expression: Expression? = nil) {
        if let expression = expression {
            state = Reference(.unresolved(header, tuples, expression))
        } else {
            state = Reference(.resolved(header, tuples))
        }
    }

    private func resolvingState() -> (header: Header, tuples: Tuples) {
        switch state.value {
        case let .resolved(h, ts):
            return (h, ts)
        case let .unresolved(h, ts, e):
            // resolve expression with h and ts to get newH and newTs
            let (newH, newTs) = (h, ts)
            state.value = .resolved(newH, newTs)
            return (newH, newTs)
        }
    }
}

public extension Relation {
     func project(_ attributes: [AttributeName]) -> Relation {
         Relation(header: header, tuples: tuples, expression: .projection(attributes, expression ?? .relation(self)))
     }
}
