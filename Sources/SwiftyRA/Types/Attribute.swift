// MARK: Value Type

public enum ValueType {
    case boolean
    case string
    case integer
    case float
}

// MARK: Attribute Type

public enum AttributeType {
    case required(ValueType)
    case optional(ValueType)
}

// MARK: Attribute Name

public typealias AttributeName = String

// MARK: Attribute

public struct Attribute {
    public let name: AttributeName
    public let type: AttributeType

    public init(name: AttributeName, type: AttributeType) {
        self.name = name
        self.type = type
    }
}

// MARK: Equality & Hashing

extension ValueType: Hashable {}
extension AttributeType: Hashable {}
extension Attribute: Hashable {}
