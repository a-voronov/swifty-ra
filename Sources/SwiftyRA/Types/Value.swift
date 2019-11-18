// TODO: think of operations with `none` value. Return `none` as well even for binary ones?

// MARK: Value

/// Values allowed to be stored in relation tuples.
/// Can be constructed using basic literals as well as enum cases.
/// Can be compared, and will throws error if values of incompatible types are compared.
public enum Value {
    case boolean(Bool)
    case string(String)
    case integer(Int)
    case float(Float)
    case none
}

// MARK: Expressing By Literals

extension Value: ExpressibleByBooleanLiteral { public init(booleanLiteral value: Bool)  { self = .boolean(value) } }
extension Value: ExpressibleByStringLiteral  { public init(stringLiteral value: String) { self = .string(value)  } }
extension Value: ExpressibleByIntegerLiteral { public init(integerLiteral value: Int)   { self = .integer(value) } }
extension Value: ExpressibleByFloatLiteral   { public init(floatLiteral value: Float)   { self = .float(value)   } }
extension Value: ExpressibleByNilLiteral     { public init(nilLiteral: ())              { self = .none           } }

// MARK: Helper Getters

public extension Value {
    var hasValue: Bool {
        self != .none
    }

    var boolean: Bool? {
        guard case let .boolean(value) = self else { return nil }
        return value
    }

    var string: String? {
        guard case let .string(value) = self else { return nil }
        return value
    }

    var integer: Int? {
        guard case let .integer(value) = self else { return nil }
        return value
    }

    var float: Float? {
        guard case let .float(value) = self else { return nil }
        return value
    }
}

// MARK: Casting

public extension Value {
    var asBoolean: Throws<Bool> {
        Throws(value: boolean, error: .mismatch(.one(self), .one(.boolean)))
    }

    var asString: Throws<String> {
        Throws(value: string, error: .mismatch(.one(self), .one(.string)))
    }

    var asInteger: Throws<Int> {
        Throws(value: integer, error: .mismatch(.one(self), .one(.integer)))
    }

    var asFloat: Throws<Float> {
        Throws(value: float, error: .mismatch(.one(self), .one(.float)))
    }
}

public extension Value {
    var type: ValueType? {
        switch self {
        case .boolean: return .boolean
        case .string:  return .string
        case .integer: return .integer
        case .float:   return .float
        case .none:    return nil
        }
    }
}

// MARK: Matching With Attribute Type

public extension Value {
    func isMatching(type: AttributeType) -> Bool {
        switch (type, self) {
        case (.required(.boolean), .boolean),
             (.required(.string),  .string),
             (.required(.integer), .integer),
             (.required(.float),   .float),

             (.optional(.boolean), .boolean),
             (.optional(.string),  .string),
             (.optional(.integer), .integer),
             (.optional(.float),   .float),

             (.optional,           .none):
            return true
        default:
            return false
        }
    }
}

// MARK: Equality & Hashing

extension Value: Hashable {}
