public typealias Tuples = [Tuple]

public struct Tuple {
    public let values: [AttributeName: Value]

    public subscript(name: AttributeName) -> Value? {
        values[name]
    }
}
