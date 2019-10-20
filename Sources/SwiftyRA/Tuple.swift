public typealias Tuples = [Tuple]

public struct Tuple {
    public let values: [AttributeName: Value]

    init(values: [AttributeName: Value]) {
        self.values = values
    }

    public subscript(name: AttributeName) -> Value? {
        values[name]
    }

    public subscript(name: AttributeName, default value: Value) -> Value {
        values[name] ?? value
    }
}
