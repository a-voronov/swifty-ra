/// Minimalistic non-empty collection of elements.
/// Not intended for big chunks of data.
/// Usually used in errors where amount of values is small, though would be nice to prove non-emptiness.
public indirect enum OneOrMore<T> {
    case one(T)
    case more(T, Self)

    var isOne: Bool {
        switch self {
        case .one: return true
        case .more: return false
        }
    }
}

// MARK: Creation simplified

public extension OneOrMore {
    static func few(_ head: T, _ tail: T...) -> OneOrMore {
        few(head, tail)
    }

    static func few<S>(_ head: T, _ tail: S) -> OneOrMore where S: Sequence, S.Element == T {
        var many: OneOrMore = .one(head)
        for value in tail {
            many = .more(value, many)
        }
        return many
    }
}

// MARK: Adding elements

public extension OneOrMore {
    mutating func add(_ other: T) {
        self = adding(other)
    }

    func adding(_ other: T) -> Self {
        .more(other, self)
    }
}

// MARK: Array representation

public extension OneOrMore {
    var array: [T] {
        switch self {
        case let .one(value):
            return [value]
        case let .more(value, other):
            var copy = other.array
            copy.append(value)
            return copy
        }
    }
}

// MARK: Set representation

public extension OneOrMore where T: Hashable {
    var set: Set<T> {
        switch self {
        case let .one(value):
            return [value]
        case let .more(value, other):
            var copy = other.set
            copy.insert(value)
            return copy
        }
    }
}

// MARK: Equatable & Hashable

extension OneOrMore: Equatable where T: Equatable {}
extension OneOrMore: Hashable where T: Hashable {}

// MARK: Debugging

extension OneOrMore: CustomDebugStringConvertible {
    public var debugDescription: String {
        guard case let .one(value) = self else {
            return array.debugDescription
        }
        return "\(value)"
    }
}

// MARK: Internal Helpers

extension OneOrMore {
    static func tupleOfFew<S>(_ lhs: (T, S), _ rhs: (T, S)) -> (OneOrMore, OneOrMore) where S: Sequence, S.Element == T {
        (few(lhs.0, lhs.1), few(rhs.0, rhs.1))
    }
}
