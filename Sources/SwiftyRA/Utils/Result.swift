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
