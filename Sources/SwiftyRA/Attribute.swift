public enum ValueType: Equatable {
    case boolean
    case string
    case integer
    case float
}

public enum AttributeType {
    case required(ValueType)
    case optional(ValueType)
}

public typealias AttributeName = String

public struct Attribute {
    let name: AttributeName
    let type: AttributeType
}
