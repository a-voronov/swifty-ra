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

// MARK: Equality & Hashing

extension Value: Hashable {}

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

// MARK: Expressing By Literals

extension Value: ExpressibleByBooleanLiteral { public init(booleanLiteral value: Bool)  { self = .boolean(value) } }
extension Value: ExpressibleByStringLiteral  { public init(stringLiteral value: String) { self = .string(value)  } }
extension Value: ExpressibleByIntegerLiteral { public init(integerLiteral value: Int)   { self = .integer(value) } }
extension Value: ExpressibleByFloatLiteral   { public init(floatLiteral value: Float)   { self = .float(value)   } }
extension Value: ExpressibleByNilLiteral     { public init(nilLiteral: ())              { self = .none           } }

// MARK: Helper getters

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

// MARK: Errors

public extension Value {
    typealias Throws<T> = Result<T, Value.Errors>

    enum Errors: Error, Hashable {
        case mismatch(Value, ExpectedType)
        case mismatches(Value, Value, ExpectedType)
        case incompatible(Value, Value)

        public enum ExpectedType: Hashable {
            case type(ValueType)
            case either(Set<ValueType>)
        }
    }
}

// MARK: Comparing Operations

public extension Value {
    static func == (lhs: Value, rhs: Value) -> Throws<Bool> {
        switch (lhs, rhs) {
        case let (.boolean(l), .boolean(r)): return .success(l == r)
        case let (.string(l),  .string(r)):  return .success(l == r)
        case let (.integer(l), .integer(r)): return .success(l == r)
        case let (.float(l),   .float(r)):   return .success(l == r)
        case     (.none,       .none):       return .success(true)

        default: return .failure(.incompatible(lhs, rhs))
        }
    }

    static func != (lhs: Value, rhs: Value) -> Throws<Bool> {
        (lhs == rhs).map(!)
    }

    static func < (lhs: Value, rhs: Value) -> Throws<Bool> {
        switch (lhs, rhs) {
        case let (.string(l),  .string(r)):  return .success(l < r)
        case let (.integer(l), .integer(r)): return .success(l < r)
        case let (.float(l),   .float(r)):   return .success(l < r)

        // if values are equal, result is false, otherwise true is always greater than false
        case (.boolean(true),  .boolean(false)): return .success(false)
        case (.boolean(false), .boolean(true)):  return .success(true)
        case (.boolean,        .boolean):        return .success(false)

        // if values are equal, result is false, otherwise non-none value is always greater than none
        case (.none, .none): return .success(false)
        case (_,     .none): return .success(false)
        case (.none, _):     return .success(true)

        default: return .failure(.incompatible(lhs, rhs))
        }
    }

    static func > (lhs: Value, rhs: Value) -> Throws<Bool> {
        rhs < lhs
    }

    static func >= (lhs: Value, rhs: Value) -> Throws<Bool> {
        (lhs > rhs).map { $0 || lhs == rhs }
    }

    static func <= (lhs: Value, rhs: Value) -> Throws<Bool> {
        (lhs < rhs).map { $0 || lhs == rhs }
    }
}

// MARK: Numeric Operations

public extension Value {
    private static func numeric(lhs: Value, rhs: Value, int: (Int, Int) -> Int, float: (Float, Float) -> Float) -> Throws<Value> {
        switch (lhs, rhs) {
        case let (.integer(l), .integer(r)): return .success(.integer(int(l, r)))
        case let (.float(l),   .float(r)):   return .success(.float(float(l, r)))

        default: return .failure(.mismatches(lhs, rhs, .either([.integer, .float])))
        }
    }

    static func + (lhs: Value, rhs: Value) -> Throws<Value> {
        numeric(lhs: lhs, rhs: rhs, int: +, float: +)
    }

    static func - (lhs: Value, rhs: Value) -> Throws<Value> {
        numeric(lhs: lhs, rhs: rhs, int: -, float: -)
    }

    static func * (lhs: Value, rhs: Value) -> Throws<Value> {
        numeric(lhs: lhs, rhs: rhs, int: *, float: *)
    }

    static func / (lhs: Value, rhs: Value) -> Throws<Value> {
        numeric(lhs: lhs, rhs: rhs, int: /, float: /)
    }

    static func % (lhs: Value, rhs: Value) -> Throws<Value> {
        Throws(
            value: zip(lhs.integer, rhs.integer).map(%).map(Value.integer),
            error: .mismatches(lhs, rhs, .type(.integer))
        )
    }

    func rounded(_ rule: FloatingPointRoundingRule) -> Throws<Value> {
        Throws(
            value: float.map { $0.rounded(rule) }.map(Value.float),
            error: .mismatch(self, .type(.float))
        )
    }
}

// MARK: String Operations

public extension Value {
    func length() -> Throws<Value> {
        Throws(
            value: string.map(\.count).map(Value.integer),
            error: .mismatch(self, .type(.string))
        )
    }

    func lower() -> Throws<Value> {
        Throws(
            value: string.map { $0.lowercased() }.map(Value.string),
            error: .mismatch(self, .type(.string))
        )
    }

    func upper() -> Throws<Value> {
        Throws(
            value: string.map { $0.uppercased() }.map(Value.string),
            error: .mismatch(self, .type(.string))
        )
    }
}

// MARK: Boolean Operations

public extension Value {
    private static func boolean(_ lhs: Value, _ rhs: Value, _ op: (Bool, Bool) -> Bool) -> Throws<Bool> {
        Throws(
            value: zip(lhs.boolean, rhs.boolean).map(op),
            error: .mismatches(lhs, rhs, .type(.boolean))
        )
    }

    static func && (lhs: Value, rhs: Value) -> Throws<Bool> {
        boolean(lhs, rhs) { $0 && $1 }
    }

    static func || (lhs: Value, rhs: Value) -> Throws<Bool> {
        boolean(lhs, rhs) { $0 || $1 }
    }

    static prefix func ! (a: Value) -> Throws<Bool> {
        Throws(
            value: a.boolean.map(!),
            error: .mismatch(a, .type(.boolean))
        )
    }
}

// MARK: Debugging

extension Value: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .boolean(value): return "\(value)"
        case let .string(value): return value.debugDescription
        case let .integer(value): return "\(value)"
        case let .float(value): return value.debugDescription
        case .none: return "nil"
        }
    }
}

extension Value.Errors.ExpectedType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .type(type): return "\(type) type"
        case let .either(types): return "either \(types.map(\.debugDescription).joined(separator: " or ")) type"
        }
    }
}

extension Value.Errors: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .mismatch(value, expectedType):
            return "Value \(value) should be of \(expectedType)"
        case let .mismatches(lhs, rhs, expectedType):
            return "Values \(lhs) and \(rhs) should be of \(expectedType)"
        case let .incompatible(lhs, rhs):
            return "Values \(lhs) and \(rhs) should be of the same type"
        }
    }
}
