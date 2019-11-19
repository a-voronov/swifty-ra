// MARK: Member

public extension MemberExpression {
    static func == (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs == rhs) }
    static func != (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs != rhs) }
    static func >  (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs >  rhs) }
    static func <  (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs <  rhs) }
    static func >= (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs >= rhs) }
    static func <= (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs <= rhs) }
}

public extension MemberExpression {
    static func && (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs && rhs) }
    static func || (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs || rhs) }

    static prefix func ! (_ exp: MemberExpression) -> AnyExpression { .boolean(!exp) }
}

public extension MemberExpression {
    static func + (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .numeric(lhs + rhs) }
    static func - (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .numeric(lhs - rhs) }
    static func * (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .numeric(lhs * rhs) }
    static func / (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .numeric(lhs / rhs) }
    static func % (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .numeric(lhs % rhs) }

    func round(_ rule: FloatingPointRoundingRule) -> AnyExpression { .numeric(round(rule)) }
}

public extension MemberExpression {
    static func ++ (_ lhs: MemberExpression, _ rhs: MemberExpression) -> AnyExpression { .string(lhs ++ rhs) }

    func lower()  -> AnyExpression { .string(lower()) }
    func upper()  -> AnyExpression { .string(upper()) }
    func length() -> AnyExpression { .numeric(length()) }
}

// MARK: Boolean

public extension BooleanExpression {
    static func == (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs == rhs) }
    static func != (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs != rhs) }
    static func >  (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs >  rhs) }
    static func <  (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs <  rhs) }
    static func >= (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs >= rhs) }
    static func <= (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs <= rhs) }

    static func == (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs == rhs) }
    static func != (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs != rhs) }
    static func >  (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs >  rhs) }
    static func <  (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs <  rhs) }
    static func >= (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs >= rhs) }
    static func <= (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs <= rhs) }

    static func == (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs == rhs) }
    static func != (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs != rhs) }
    static func >  (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs >  rhs) }
    static func <  (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs <  rhs) }
    static func >= (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs >= rhs) }
    static func <= (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs <= rhs) }
}

public extension BooleanExpression {
    static func && (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs && rhs) }
    static func || (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs || rhs) }

    static func && (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs && rhs) }
    static func || (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> AnyExpression { .boolean(lhs || rhs) }

    static func && (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs && rhs) }
    static func || (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs || rhs) }

    static prefix func ! (_ exp: BooleanExpression) -> AnyExpression { .boolean(!exp) }
}

// MARK: Numeric

public extension NumericExpression {
    static func == (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs == rhs) }
    static func != (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs != rhs) }
    static func >  (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs >  rhs) }
    static func <  (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs <  rhs) }
    static func >= (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs >= rhs) }
    static func <= (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs <= rhs) }

    static func == (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs == rhs) }
    static func != (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs != rhs) }
    static func >  (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs >  rhs) }
    static func <  (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs <  rhs) }
    static func >= (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs >= rhs) }
    static func <= (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .boolean(lhs <= rhs) }

    static func == (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs == rhs) }
    static func != (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs != rhs) }
    static func >  (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs >  rhs) }
    static func <  (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs <  rhs) }
    static func >= (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs >= rhs) }
    static func <= (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs <= rhs) }
}

public extension NumericExpression {
    static func + (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .numeric(lhs + rhs) }
    static func - (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .numeric(lhs - rhs) }
    static func * (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .numeric(lhs * rhs) }
    static func / (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .numeric(lhs / rhs) }
    static func % (_ lhs: NumericExpression, _ rhs: NumericExpression) -> AnyExpression { .numeric(lhs % rhs) }

    static func + (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .numeric(lhs + rhs) }
    static func - (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .numeric(lhs - rhs) }
    static func * (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .numeric(lhs * rhs) }
    static func / (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .numeric(lhs / rhs) }
    static func % (_ lhs: MemberExpression, _ rhs: NumericExpression) -> AnyExpression { .numeric(lhs % rhs) }

    static func + (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .numeric(lhs + rhs) }
    static func - (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .numeric(lhs - rhs) }
    static func * (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .numeric(lhs * rhs) }
    static func / (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .numeric(lhs / rhs) }
    static func % (_ lhs: NumericExpression, _ rhs: MemberExpression) -> AnyExpression { .numeric(lhs % rhs) }

    func round(_ rule: FloatingPointRoundingRule) -> AnyExpression { .numeric(round(rule)) }
}

// MARK: String

public extension StringExpression {
    static func == (_ lhs: StringExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs == rhs) }
    static func != (_ lhs: StringExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs != rhs) }
    static func >  (_ lhs: StringExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs >  rhs) }
    static func <  (_ lhs: StringExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs <  rhs) }
    static func >= (_ lhs: StringExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs >= rhs) }
    static func <= (_ lhs: StringExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs <= rhs) }

    static func == (_ lhs: MemberExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs == rhs) }
    static func != (_ lhs: MemberExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs != rhs) }
    static func >  (_ lhs: MemberExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs >  rhs) }
    static func <  (_ lhs: MemberExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs <  rhs) }
    static func >= (_ lhs: MemberExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs >= rhs) }
    static func <= (_ lhs: MemberExpression, _ rhs: StringExpression) -> AnyExpression { .boolean(lhs <= rhs) }

    static func == (_ lhs: StringExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs == rhs) }
    static func != (_ lhs: StringExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs != rhs) }
    static func >  (_ lhs: StringExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs >  rhs) }
    static func <  (_ lhs: StringExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs <  rhs) }
    static func >= (_ lhs: StringExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs >= rhs) }
    static func <= (_ lhs: StringExpression, _ rhs: MemberExpression) -> AnyExpression { .boolean(lhs <= rhs) }
}

public extension StringExpression {
    static func ++ (_ lhs: StringExpression, _ rhs: StringExpression) -> AnyExpression { .string(lhs ++ rhs) }

    static func ++ (_ lhs: MemberExpression, _ rhs: StringExpression) -> AnyExpression { .string(lhs ++ rhs) }

    static func ++ (_ lhs: StringExpression, _ rhs: MemberExpression) -> AnyExpression { .string(lhs ++ rhs) }

    func lower()  -> AnyExpression { .string(lower()) }
    func upper()  -> AnyExpression { .string(upper()) }
    func length() -> AnyExpression { .numeric(length()) }
}

//public func atr(_ atr: AttributeName) -> AnyExpression { .member(.atr(atr)) }
//public func val(_ val: Value) -> AnyExpression         { .member(.val(val)) }

//extension AnyExpression: ExpressibleByBooleanLiteral { public init(booleanLiteral value: Bool)  { self = .member(MemberExpression(booleanLiteral: value)) }}
//extension AnyExpression: ExpressibleByStringLiteral  { public init(stringLiteral value: String) { self = .member(MemberExpression(stringLiteral: value)) }}
//extension AnyExpression: ExpressibleByIntegerLiteral { public init(integerLiteral value: Int)   { self = .member(MemberExpression(integerLiteral: value)) }}
//extension AnyExpression: ExpressibleByFloatLiteral   { public init(floatLiteral value: Float)   { self = .member(MemberExpression(floatLiteral: value)) }}
//extension AnyExpression: ExpressibleByNilLiteral     { public init(nilLiteral: ())              { self = .member(MemberExpression(nilLiteral: ())) }}
