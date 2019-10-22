public typealias Tuples = [Tuple]

/// Stores values by attribute name.
/// Doesn't preserve values order.
/// Allows dynamic member access via property as well as via usual subscript by name.
@dynamicMemberLookup
public struct Tuple {
    public private(set) var values: [AttributeName: Value]

    public init(values: [AttributeName: Value]) {
        self.values = values
    }

    public subscript(name: AttributeName) -> Value? {
        values[name]
    }

    public subscript(name: AttributeName, default value: Value) -> Value {
        values[name, default: value]
    }

    public subscript(dynamicMember member: AttributeName) -> Value {
        self[member, default: .none]
    }
}

extension Tuple {
    mutating func rename(to: AttributeName, from: AttributeName) {
        values[to] = values.removeValue(forKey: from) ?? Value.none
    }
}
