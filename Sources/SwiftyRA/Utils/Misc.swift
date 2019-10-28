/// Reference value wrapper
final class Reference<Value> {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}

/// Helper to update value's mutable properties
func updating<T>(_ value: T, _ transform: (inout T) throws -> Void) rethrows -> T {
    var newValue = value
    try transform(&newValue)
    return newValue
}
