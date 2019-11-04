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

// MARK: Debugging

extension ValueType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .boolean: return "Bool"
        case .string:  return "String"
        case .integer: return "Int"
        case .float:   return "Float"
        }
    }
}

extension AttributeType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .required(valueType): return valueType.debugDescription
        case let .optional(valueType): return valueType.debugDescription + "?"
        }
    }
}

extension Attribute: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Attribute(" + name + ": " + type.debugDescription + ")"
    }
}
