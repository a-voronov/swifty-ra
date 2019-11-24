public extension Value {
    static func + (lhs: Value, rhs: Value) -> Throws<Value> {
        binary(lhs: lhs, rhs: rhs, int: +, float: +)
    }

    static func - (lhs: Value, rhs: Value) -> Throws<Value> {
        binary(lhs: lhs, rhs: rhs, int: -, float: -)
    }

    static func * (lhs: Value, rhs: Value) -> Throws<Value> {
        binary(lhs: lhs, rhs: rhs, int: *, float: *)
    }

    static func / (lhs: Value, rhs: Value) -> Throws<Value> {
        binary(lhs: lhs, rhs: rhs, int: /, float: /)
    }

    static func % (lhs: Value, rhs: Value) -> Throws<Value> {
        binary(lhs: lhs, rhs: rhs, int: %, float: nil)
    }

    func rounded(_ rule: FloatingPointRoundingRule) -> Throws<Value> {
        unary { $0.rounded(rule) }
    }

    private func unary(transform: (Float) -> Float) -> Throws<Value> {
        Throws(
            value: floatValue.map { $0.map(transform).map(Value.float) ?? .none },
            error: .mismatch(.one(self), .one(.float))
        )
    }

    private static func binary(lhs: Value, rhs: Value, int: (Int, Int) -> Int, float: ((Float, Float) -> Float)?) -> Throws<Value> {
        switch (lhs, rhs) {
        case let (.integer(l), .integer(r)):
            return .success(.integer(int(l, r)))
        case let (.float(l), .float(r)):
            guard let float = float else {
                return .failure(.mismatch(.few(lhs, rhs), .one(.integer)))
            }
            return .success(.float(float(l, r)))
        case (.none, .integer),
             (.integer, .none),
             (.none, .float),
             (.float, .none):
            return .success(.none)
        default:
            return .failure(.mismatch(.few(lhs, rhs), .few(.integer, .float)))
        }
    }
}
