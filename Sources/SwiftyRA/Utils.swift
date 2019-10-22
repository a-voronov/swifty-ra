@dynamicMemberLookup
final class Reference<Value> {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }

    subscript<T>(dynamicMember member: KeyPath<Value, T>) -> T {
        value[keyPath: member]
    }

    subscript<T>(dynamicMember member: WritableKeyPath<Value, T>) -> T {
        get { value[keyPath: member] }
        set { value[keyPath: member] = newValue }
    }
}

public extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }
}

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

extension Result {
    func map<T>(_ keyPath: KeyPath<Success, T>) -> Result<T, Failure> {
        map { $0[keyPath: keyPath] }
    }

    func flatMap<T>(_ keyPath: KeyPath<Success, Result<T, Failure>>) -> Result<T, Failure> {
        flatMap { $0[keyPath: keyPath] }
    }
}

func updating<T>(_ value: T, _ transform: (inout T) -> Void) -> T {
    var newValue = value
    transform(&newValue)
    return newValue
}
