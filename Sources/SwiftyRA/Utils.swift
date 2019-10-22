/// Reference value wrapper
final class Reference<Value> {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}

/// Collection isNotEmpty
public extension Collection {
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

    func flatMap<T>(_ keyPath: KeyPath<Success, Result<T, Failure>>) -> Result<T, Failure> {
        flatMap { $0[keyPath: keyPath] }
    }
}

/// Helper to update value's mutable properties
func updating<T>(_ value: T, _ transform: (inout T) -> Void) -> T {
    var newValue = value
    transform(&newValue)
    return newValue
}
