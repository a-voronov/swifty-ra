public extension Value {
    private static func boolean(_ lhs: Value, _ rhs: Value, _ op: (Bool, Bool) -> Bool) -> Throws<Bool> {
        Throws(
            value: zip(lhs.boolean, rhs.boolean).map(op),
            error: .mismatch(.few(lhs, rhs), .one(.boolean))
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
            error: .mismatch(.one(a), .one(.boolean))
        )
    }
}
