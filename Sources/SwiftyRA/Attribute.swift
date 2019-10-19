public enum ValueType: Equatable {
    case boolean
    case string
    case integer
    case float
}

public enum AttributeType: Equatable {
    case required(ValueType)
    case optional(ValueType)
}

public typealias AttributeName = String

public struct Attribute: Equatable {
    public let name: AttributeName
    public let type: AttributeType

    public init(name: AttributeName, type: AttributeType) {
        self.name = name
        self.type = type
    }
}
