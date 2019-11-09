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
