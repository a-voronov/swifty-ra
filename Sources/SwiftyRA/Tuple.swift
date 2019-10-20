public typealias Tuples = [Tuple]

@dynamicMemberLookup
public struct Tuple {
    public let values: [AttributeName: Value]

    init(values: [AttributeName: Value]) {
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
