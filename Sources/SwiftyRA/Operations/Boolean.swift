public extension Value {
    static func && (lhs: Value, rhs: Value) -> Throws<Value> {
        binary(lhs: lhs, rhs: rhs) { $0 && $1 }
    }

    static func || (lhs: Value, rhs: Value) -> Throws<Value> {
        binary(lhs: lhs, rhs: rhs) { $0 || $1 }
    }

    static prefix func ! (a: Value) -> Throws<Value> {
        a.unary(transform: !)
    }

    private func unary(transform: (Bool) -> Bool) -> Throws<Value> {
        Throws(
            value: booleanValue.map { $0.map(transform).map(Value.boolean) ?? .none },
            error: .mismatch(.one(self), .one(.boolean))
        )
    }

    private static func binary(lhs: Value, rhs: Value, transform: (Bool, Bool) -> Bool) -> Throws<Value> {
        Throws(
            value: zip(lhs.booleanValue, rhs.booleanValue).map { l, r in zip(l, r).map(transform).map(Value.boolean) ?? .none },
            error: .mismatch(.few(lhs, rhs), .one(.boolean))
        )
    }
}
