/// Values allowed to be stored in relation tuples.
/// Can be constructed using basic literals as well as enum cases.
/// Can be compared, and will throws error if values of incompatible types are compared.
public enum Value: Hashable {
    case boolean(Bool)
    case string(String)
    case integer(Int)
    case float(Float)
    case none
}

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

extension Value: ExpressibleByBooleanLiteral { public init(booleanLiteral value: Bool)  { self = .boolean(value) } }
extension Value: ExpressibleByStringLiteral  { public init(stringLiteral value: String) { self = .string(value)  } }
extension Value: ExpressibleByIntegerLiteral { public init(integerLiteral value: Int)   { self = .integer(value) } }
extension Value: ExpressibleByFloatLiteral   { public init(floatLiteral value: Float)   { self = .float(value)   } }
extension Value: ExpressibleByNilLiteral     { public init(nilLiteral: ())              { self = .none           } }

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

extension Value {
    public enum Errors: Error {
        case incompatible(Value, Value)
    }

    public static func < (lhs: Value, rhs: Value) throws -> Bool {
        switch (lhs, rhs) {
        case let (.string(l),  .string(r)):  return l < r
        case let (.integer(l), .integer(r)): return l < r
        case let (.float(l),   .float(r)):   return l < r

        // numbers can be compared by treating integer as a number with floating point
        case let (.float(l),   .integer(r)):   return l < Float(r)
        case let (.integer(l),   .float(r)):   return Float(l) < r

        // if values are equal, result is false, otherwise true is always greater than false
        case (.boolean(true),  .boolean(false)): return false
        case (.boolean(false), .boolean(true)):  return true
        case (.boolean,        .boolean):        return false

        // if values are equal, result is false, otherwise non-none value is always greater than none
        case (.none, .none): return false
        case (_,     .none): return false
        case (.none, _):     return true

        default: throw Errors.incompatible(lhs, rhs)
        }
    }

    public static func > (lhs: Value, rhs: Value) throws -> Bool {
        try rhs < lhs
    }
}
