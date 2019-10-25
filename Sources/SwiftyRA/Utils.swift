/// Reference value wrapper
final class Reference<Value> {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}

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

/// These type, that represents either one, or another, or both values
enum These<A, B> {
    case this(A)
    case that(B)
    case these(A, B)
}

extension These: Error where A: Error, B: Error {}

extension These {
    init?(_ a: A?, b: B?) {
        switch (a, b) {
        case let (a?, b?): self = .these(a, b)
        case let (a?, nil): self = .this(a)
        case let (nil, b?): self = .that(b)
        case (nil, nil): return nil
        }
    }
}

/// Collection isNotEmpty
extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }
}

/// Sequence KeyPath extensions
extension Sequence {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        map { $0[keyPath: keyPath] }
    }

    func compactMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
        compactMap { $0[keyPath: keyPath] }
    }

    func flatMap<T>(_ keyPath: KeyPath<Element, [T]>) -> [T] {
        flatMap { $0[keyPath: keyPath] }
    }

    func filter(_ keyPath: KeyPath<Element, Bool>) -> [Element] {
        filter { $0[keyPath: keyPath] }
    }
}

/// Result value, error properties helpers
extension Result {
    var value: Success? {
        guard case let .success(v) = self else {
            return nil
        }
        return v
    }

    var error: Failure? {
        guard case let .failure(e) = self else {
            return nil
        }
        return e
    }
}

/// Result KeyPath extensions
extension Result {
    func map<T>(_ keyPath: KeyPath<Success, T>) -> Result<T, Failure> {
        map { $0[keyPath: keyPath] }
    }

    func mapError<T: Error>(_ keyPath: KeyPath<Failure, T>) -> Result<Success, T> {
        mapError { $0[keyPath: keyPath] }
    }

    func flatMap<T>(_ keyPath: KeyPath<Success, Result<T, Failure>>) -> Result<T, Failure> {
        flatMap { $0[keyPath: keyPath] }
    }

    func flatMapError<T: Error>(_ keyPath: KeyPath<Failure, Result<Success, T>>) -> Result<Success, T> {
        flatMapError { $0[keyPath: keyPath] }
    }
}

/// Zip 2 Results
func zip<A, B, E: Error, F: Error>(_ a: Result<A, E>, _ b: Result<B, F>) -> Result<(A, B), Either<E, F>> {
    a.mapError(Either.left).flatMap { a in
        b.mapError(Either.right).flatMap { b in .success((a, b)) }
    }
}

/// Helper to update value's mutable properties
func updating<T>(_ value: T, _ transform: (inout T) -> Void) -> T {
    var newValue = value
    transform(&newValue)
    return newValue
}
