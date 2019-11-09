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
}
