// TODO: See 3VL for correct implementation: https://en.wikipedia.org/wiki/Three-valued_logic

public extension Value {
    static func == (lhs: Value, rhs: Value) -> Throws<Value> {
        switch (lhs, rhs) {
        case let (.boolean(l), .boolean(r)): return .success(.boolean(l == r))
        case let (.string(l),  .string(r)):  return .success(.boolean(l == r))
        case let (.integer(l), .integer(r)): return .success(.boolean(l == r))
        case let (.float(l),   .float(r)):   return .success(.boolean(l == r))
        case     (.none,       .none):       return .success(.boolean(true))
        case     (.none,       _):           return .success(.boolean(false))
        case     (_,           .none):       return .success(.boolean(false))

        default: return .failure(.incompatible(lhs, rhs))
        }
    }

    static func != (lhs: Value, rhs: Value) -> Throws<Value> {
        (lhs == rhs).flatMap(!)
    }

    static func < (lhs: Value, rhs: Value) -> Throws<Value> {
        switch (lhs, rhs) {
        case let (.string(l),  .string(r)):  return .success(.boolean(l < r))
        case let (.integer(l), .integer(r)): return .success(.boolean(l < r))
        case let (.float(l),   .float(r)):   return .success(.boolean(l < r))

        // if values are equal, result is false, otherwise true is always greater than false
        case (.boolean(true),  .boolean(false)): return .success(.boolean(false))
        case (.boolean(false), .boolean(true)):  return .success(.boolean(true))
        case (.boolean,        .boolean):        return .success(.boolean(false))

        // if values are equal, result is false, otherwise non-none value is always greater than none
        case (.none, .none): return .success(.boolean(false))
        case (_,     .none): return .success(.boolean(false))
        case (.none, _):     return .success(.boolean(true))

        default: return .failure(.incompatible(lhs, rhs))
        }
    }

    static func > (lhs: Value, rhs: Value) -> Throws<Value> {
        rhs < lhs
    }

    static func >= (lhs: Value, rhs: Value) -> Throws<Value> {
        (lhs > rhs).flatMap { result in
            guard result == .boolean(true) else {
                return lhs == rhs
            }
            return .success(result)
        }
    }

    static func <= (lhs: Value, rhs: Value) -> Throws<Value> {
        (lhs < rhs).flatMap { result in
            guard result == .boolean(true) else {
                return lhs == rhs
            }
            return .success(result)
        }
    }
}
