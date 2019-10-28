/// Either type, that represetnts either one, or another value
enum Either<A, B> {
    case left(A)
    case right(B)
}

/// Either as Error
extension Either: Error where A: Error, B: Error {}

/// Either value if types are the same
extension Either where A == B {
    var value: A {
        switch self {
        case let .left(v): return v
        case let .right(v): return v
        }
    }
}

extension Either {
    var left: A? {
        get {
            guard case let .left(v) = self else { return nil }
            return v
        }
        set {
            guard let v = newValue else { return }
            self = .left(v)
        }
    }

    var right: B? {
        get {
            guard case let .right(v) = self else { return nil }
            return v
        }
        set {
            guard let v = newValue else { return }
            self = .right(v)
        }
    }

    func mapLeft<T>(_ transform: (A) throws -> T) rethrows -> Either<T, B> {
        switch self {
        case let .left(v): return try .left(transform(v))
        case let .right(v): return .right(v)
        }
    }

    func mapRight<T>(_ transform: (B) throws -> T) rethrows -> Either<A, T> {
        switch self {
        case let .left(v): return .left(v)
        case let .right(v): return try .right(transform(v))
        }
    }
}
