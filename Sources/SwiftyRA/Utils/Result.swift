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

/// The only possible value is Success if it Never fails
extension Result where Failure == Never {
    var only: Success {
        value!
    }
}

/// The only possible value is Failure if it Never succeeds
extension Result where Success == Never {
    var only: Failure {
        error!
    }
}

/// Shortcut to ommit extra parentheses when Success is Void
extension Result where Success == Void {
    static func success() -> Result {
        .success(())
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

/// Initialize from optional with error if value is nil
extension Result {
    init(value: Success?, error: Failure) {
        self = value.map(Result.success) ?? .failure(error)
    }
}
