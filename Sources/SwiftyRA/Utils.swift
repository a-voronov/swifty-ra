final class Reference<Value> {
    var value: Value

    init(_ value: Value) {
        self.value = value
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
