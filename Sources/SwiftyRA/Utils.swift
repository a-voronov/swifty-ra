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
        return !isEmpty
    }
}

extension Sequence {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }

    func compactMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
        return compactMap { $0[keyPath: keyPath] }
    }

    func flatMap<T>(_ keyPath: KeyPath<Element, [T]>) -> [T] {
        return flatMap { $0[keyPath: keyPath] }
    }

    func filter(_ keyPath: KeyPath<Element, Bool>) -> [Element] {
        return filter { $0[keyPath: keyPath] }
    }
}

func updating<T>(_ value: T, _ transform: (inout T) -> Void) -> T {
    var newValue = value
    transform(&newValue)
    return newValue
}
