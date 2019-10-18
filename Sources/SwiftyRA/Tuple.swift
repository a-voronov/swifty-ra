public typealias Tuples = [Tuple]

public struct Tuple {
    // TODO: associate name with some id (UUID, UInt, ...), so that renaming can be cheap
    
    public let values: [AttributeName: Value]

    public subscript(name: AttributeName) -> Value? {
        values[name]
    }
}
