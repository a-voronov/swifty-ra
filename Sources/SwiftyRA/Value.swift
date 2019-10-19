// TODO: extend Value with boolean operations on its types (Value == 2, Value > 42, Value != "hello", ...)

public enum Value: Equatable {
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
    public static func < (lhs: Value, rhs: Value) throws -> Bool {
        switch (lhs, rhs) {
        case let (.string(l),  .string(r)):  return l < r
        case let (.integer(l), .integer(r)): return l < r
        case let (.float(l),   .float(r)):   return l < r

        // if values are equal, result is false, otherwise true is always greater than false
        case (.boolean(true),  .boolean(false)): return false
        case (.boolean(false), .boolean(true)):  return true
        case (.boolean,        .boolean):        return false

        // if values are equal, result is false, otherwise non-null value is always greater than none
        case (.none, .none): return false
        case (_,     .none): return false
        case (.none, _):     return true

        default: throw Errors.incompatibleValues(lhs, rhs)
        }
    }
}
