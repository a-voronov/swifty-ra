public extension Value {
    private static func numeric(lhs: Value, rhs: Value, int: (Int, Int) -> Int, float: (Float, Float) -> Float) -> Throws<Value> {
        switch (lhs, rhs) {
        case let (.integer(l), .integer(r)): return .success(.integer(int(l, r)))
        case let (.float(l),   .float(r)):   return .success(.float(float(l, r)))

        default: return .failure(.mismatch(.few(lhs, rhs), .few(.integer, .float)))
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
            error: .mismatch(.few(lhs, rhs), .one(.integer))
        )
    }

    func rounded(_ rule: FloatingPointRoundingRule) -> Throws<Value> {
        Throws(
            value: float.map { $0.rounded(rule) }.map(Value.float),
            error: .mismatch(.one(self), .one(.float))
        )
    }
}
