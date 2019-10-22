public enum ValueType: Hashable {
    case boolean
    case string
    case integer
    case float
}

public enum AttributeType: Hashable {
    case required(ValueType)
    case optional(ValueType)
}

public typealias AttributeName = String

public struct Attribute: Hashable {
    public let name: AttributeName
    public let type: AttributeType

    public init(name: AttributeName, type: AttributeType) {
        self.name = name
        self.type = type
    }
}
