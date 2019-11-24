infix operator ++: AdditionPrecedence

public extension Value {
    func length() -> Throws<Value> {
        unary { string in .integer(string.count) }
    }

    func lower() -> Throws<Value> {
        unary { string in .string(string.lowercased()) }
    }

    func upper() -> Throws<Value> {
        unary { string in .string(string.uppercased()) }
    }

    static func ++ (lhs: Value, rhs: Value) -> Throws<Value> {
        binary(lhs: lhs, rhs: rhs, transform: +)
    }

    private func unary(transform: (String) -> Value) -> Throws<Value> {
        Throws(
            value: stringValue.map { $0.map(transform) ?? .none },
            error: .mismatch(.one(self), .one(.string))
        )
    }

    private static func binary(lhs: Value, rhs: Value, transform: (String, String) -> String) -> Throws<Value> {
        Throws(
            value: zip(lhs.stringValue, rhs.stringValue).map { l, r in zip(l, r).map(transform).map(Value.string) ?? .none },
            error: .mismatch(.few(lhs, rhs), .one(.string))
        )
    }
}
