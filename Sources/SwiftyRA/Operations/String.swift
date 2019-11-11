infix operator ++: AdditionPrecedence

public extension Value {
    func length() -> Throws<Value> {
        Throws(
            value: string.map(\.count).map(Value.integer),
            error: .mismatch(.one(self), .one(.string))
        )
    }

    func lower() -> Throws<Value> {
        Throws(
            value: string.map { $0.lowercased() }.map(Value.string),
            error: .mismatch(.one(self), .one(.string))
        )
    }

    func upper() -> Throws<Value> {
        Throws(
            value: string.map { $0.uppercased() }.map(Value.string),
            error: .mismatch(.one(self), .one(.string))
        )
    }

    static func ++ (lhs: Value, rhs: Value) -> Throws<Value> {
        Throws(
            value: zip(lhs.string, rhs.string).map(+).map(Value.string),
            error: .mismatch(.few(lhs, rhs), .one(.string))
        )
    }
}
