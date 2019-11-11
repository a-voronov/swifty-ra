// MARK: Member

public extension MemberExpression {
    static func == (_ lhs: MemberExpression, _ rhs: MemberExpression) -> BooleanExpression { .eq(.any(lhs, rhs)) }
    static func != (_ lhs: MemberExpression, _ rhs: MemberExpression) -> BooleanExpression { .neq(.any(lhs, rhs)) }
    static func >  (_ lhs: MemberExpression, _ rhs: MemberExpression) -> BooleanExpression { .gt(.any(lhs, rhs)) }
    static func <  (_ lhs: MemberExpression, _ rhs: MemberExpression) -> BooleanExpression { .lt(.any(lhs, rhs)) }
    static func >= (_ lhs: MemberExpression, _ rhs: MemberExpression) -> BooleanExpression { .ge(.any(lhs, rhs)) }
    static func <= (_ lhs: MemberExpression, _ rhs: MemberExpression) -> BooleanExpression { .le(.any(lhs, rhs)) }
}

public extension MemberExpression {
    static func && (_ lhs: MemberExpression, _ rhs: MemberExpression) -> BooleanExpression { .and(.just(lhs), .just(rhs)) }
    static func || (_ lhs: MemberExpression, _ rhs: MemberExpression) -> BooleanExpression { .or(.just(lhs), .just(rhs)) }

    static prefix func ! (_ exp: MemberExpression) -> BooleanExpression { .not(.just(exp)) }
}

public extension MemberExpression {
    static func + (_ lhs: MemberExpression, _ rhs: MemberExpression) -> NumericExpression { .add(.just(lhs), .just(rhs)) }
    static func - (_ lhs: MemberExpression, _ rhs: MemberExpression) -> NumericExpression { .sub(.just(lhs), .just(rhs)) }
    static func * (_ lhs: MemberExpression, _ rhs: MemberExpression) -> NumericExpression { .mul(.just(lhs), .just(rhs)) }
    static func / (_ lhs: MemberExpression, _ rhs: MemberExpression) -> NumericExpression { .div(.just(lhs), .just(rhs)) }
    static func % (_ lhs: MemberExpression, _ rhs: MemberExpression) -> NumericExpression { .mod(.just(lhs), .just(rhs)) }

    func round(_ rule: FloatingPointRoundingRule) -> NumericExpression { .round(rule, .just(self)) }
}

public extension MemberExpression {
    static func ++ (_ lhs: MemberExpression, _ rhs: MemberExpression) -> StringExpression { .concat(.just(lhs), .just(rhs)) }

    func lower()  -> StringExpression  { .lower(.just(self)) }
    func upper()  -> StringExpression  { .upper(.just(self)) }
    func length() -> NumericExpression { .length(.just(self)) }
}

// MARK: Boolean

public extension BooleanExpression {
    static func == (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> BooleanExpression { .eq(.boolean(lhs, rhs)) }
    static func != (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> BooleanExpression { .neq(.boolean(lhs, rhs)) }
    static func >  (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> BooleanExpression { .gt(.boolean(lhs, rhs)) }
    static func <  (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> BooleanExpression { .lt(.boolean(lhs, rhs)) }
    static func >= (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> BooleanExpression { .ge(.boolean(lhs, rhs)) }
    static func <= (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> BooleanExpression { .le(.boolean(lhs, rhs)) }

    static func == (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> BooleanExpression { .eq(.boolean(.just(lhs), rhs)) }
    static func != (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> BooleanExpression { .neq(.boolean(.just(lhs), rhs)) }
    static func >  (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> BooleanExpression { .gt(.boolean(.just(lhs), rhs)) }
    static func <  (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> BooleanExpression { .lt(.boolean(.just(lhs), rhs)) }
    static func >= (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> BooleanExpression { .ge(.boolean(.just(lhs), rhs)) }
    static func <= (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> BooleanExpression { .le(.boolean(.just(lhs), rhs)) }

    static func == (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> BooleanExpression { .eq(.boolean(lhs, .just(rhs))) }
    static func != (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> BooleanExpression { .neq(.boolean(lhs, .just(rhs))) }
    static func >  (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> BooleanExpression { .gt(.boolean(lhs, .just(rhs))) }
    static func <  (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> BooleanExpression { .lt(.boolean(lhs, .just(rhs))) }
    static func >= (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> BooleanExpression { .ge(.boolean(lhs, .just(rhs))) }
    static func <= (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> BooleanExpression { .le(.boolean(lhs, .just(rhs))) }
}

public extension BooleanExpression {
    static func && (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> BooleanExpression { .and(lhs, rhs) }
    static func || (_ lhs: BooleanExpression, _ rhs: BooleanExpression) -> BooleanExpression { .or(lhs, rhs) }

    static func && (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> BooleanExpression { .and(.just(lhs), rhs) }
    static func || (_ lhs: MemberExpression, _ rhs: BooleanExpression) -> BooleanExpression { .or(.just(lhs), rhs) }

    static func && (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> BooleanExpression { .and(lhs, .just(rhs)) }
    static func || (_ lhs: BooleanExpression, _ rhs: MemberExpression) -> BooleanExpression { .or(lhs, .just(rhs)) }

    static prefix func ! (_ exp: BooleanExpression) -> BooleanExpression { .not(exp) }
}

// MARK: Numeric

public extension NumericExpression {
    static func == (_ lhs: NumericExpression, _ rhs: NumericExpression) -> BooleanExpression { .eq(.numeric(lhs, rhs)) }
    static func != (_ lhs: NumericExpression, _ rhs: NumericExpression) -> BooleanExpression { .neq(.numeric(lhs, rhs)) }
    static func >  (_ lhs: NumericExpression, _ rhs: NumericExpression) -> BooleanExpression { .gt(.numeric(lhs, rhs)) }
    static func <  (_ lhs: NumericExpression, _ rhs: NumericExpression) -> BooleanExpression { .lt(.numeric(lhs, rhs)) }
    static func >= (_ lhs: NumericExpression, _ rhs: NumericExpression) -> BooleanExpression { .ge(.numeric(lhs, rhs)) }
    static func <= (_ lhs: NumericExpression, _ rhs: NumericExpression) -> BooleanExpression { .le(.numeric(lhs, rhs)) }

    static func == (_ lhs: MemberExpression, _ rhs: NumericExpression) -> BooleanExpression { .eq(.numeric(.just(lhs), rhs)) }
    static func != (_ lhs: MemberExpression, _ rhs: NumericExpression) -> BooleanExpression { .neq(.numeric(.just(lhs), rhs)) }
    static func >  (_ lhs: MemberExpression, _ rhs: NumericExpression) -> BooleanExpression { .gt(.numeric(.just(lhs), rhs)) }
    static func <  (_ lhs: MemberExpression, _ rhs: NumericExpression) -> BooleanExpression { .lt(.numeric(.just(lhs), rhs)) }
    static func >= (_ lhs: MemberExpression, _ rhs: NumericExpression) -> BooleanExpression { .ge(.numeric(.just(lhs), rhs)) }
    static func <= (_ lhs: MemberExpression, _ rhs: NumericExpression) -> BooleanExpression { .le(.numeric(.just(lhs), rhs)) }

    static func == (_ lhs: NumericExpression, _ rhs: MemberExpression) -> BooleanExpression { .eq(.numeric(lhs, .just(rhs))) }
    static func != (_ lhs: NumericExpression, _ rhs: MemberExpression) -> BooleanExpression { .neq(.numeric(lhs, .just(rhs))) }
    static func >  (_ lhs: NumericExpression, _ rhs: MemberExpression) -> BooleanExpression { .gt(.numeric(lhs, .just(rhs))) }
    static func <  (_ lhs: NumericExpression, _ rhs: MemberExpression) -> BooleanExpression { .lt(.numeric(lhs, .just(rhs))) }
    static func >= (_ lhs: NumericExpression, _ rhs: MemberExpression) -> BooleanExpression { .ge(.numeric(lhs, .just(rhs))) }
    static func <= (_ lhs: NumericExpression, _ rhs: MemberExpression) -> BooleanExpression { .le(.numeric(lhs, .just(rhs))) }
}

public extension NumericExpression {
    static func + (_ lhs: NumericExpression, _ rhs: NumericExpression) -> NumericExpression { .add(lhs, rhs) }
    static func - (_ lhs: NumericExpression, _ rhs: NumericExpression) -> NumericExpression { .sub(lhs, rhs) }
    static func * (_ lhs: NumericExpression, _ rhs: NumericExpression) -> NumericExpression { .mul(lhs, rhs) }
    static func / (_ lhs: NumericExpression, _ rhs: NumericExpression) -> NumericExpression { .div(lhs, rhs) }
    static func % (_ lhs: NumericExpression, _ rhs: NumericExpression) -> NumericExpression { .mod(lhs, rhs) }

    static func + (_ lhs: MemberExpression, _ rhs: NumericExpression) -> NumericExpression { .add(.just(lhs), rhs) }
    static func - (_ lhs: MemberExpression, _ rhs: NumericExpression) -> NumericExpression { .sub(.just(lhs), rhs) }
    static func * (_ lhs: MemberExpression, _ rhs: NumericExpression) -> NumericExpression { .mul(.just(lhs), rhs) }
    static func / (_ lhs: MemberExpression, _ rhs: NumericExpression) -> NumericExpression { .div(.just(lhs), rhs) }
    static func % (_ lhs: MemberExpression, _ rhs: NumericExpression) -> NumericExpression { .mod(.just(lhs), rhs) }

    static func + (_ lhs: NumericExpression, _ rhs: MemberExpression) -> NumericExpression { .add(lhs, .just(rhs)) }
    static func - (_ lhs: NumericExpression, _ rhs: MemberExpression) -> NumericExpression { .sub(lhs, .just(rhs)) }
    static func * (_ lhs: NumericExpression, _ rhs: MemberExpression) -> NumericExpression { .mul(lhs, .just(rhs)) }
    static func / (_ lhs: NumericExpression, _ rhs: MemberExpression) -> NumericExpression { .div(lhs, .just(rhs)) }
    static func % (_ lhs: NumericExpression, _ rhs: MemberExpression) -> NumericExpression { .mod(lhs, .just(rhs)) }

    func round(_ rule: FloatingPointRoundingRule) -> NumericExpression { .round(rule, self) }
}

// MARK: String

public extension StringExpression {
    static func == (_ lhs: StringExpression, _ rhs: StringExpression) -> BooleanExpression { .eq(.string(lhs, rhs)) }
    static func != (_ lhs: StringExpression, _ rhs: StringExpression) -> BooleanExpression { .neq(.string(lhs, rhs)) }
    static func >  (_ lhs: StringExpression, _ rhs: StringExpression) -> BooleanExpression { .gt(.string(lhs, rhs)) }
    static func <  (_ lhs: StringExpression, _ rhs: StringExpression) -> BooleanExpression { .lt(.string(lhs, rhs)) }
    static func >= (_ lhs: StringExpression, _ rhs: StringExpression) -> BooleanExpression { .ge(.string(lhs, rhs)) }
    static func <= (_ lhs: StringExpression, _ rhs: StringExpression) -> BooleanExpression { .le(.string(lhs, rhs)) }

    static func == (_ lhs: MemberExpression, _ rhs: StringExpression) -> BooleanExpression { .eq(.string(.just(lhs), rhs)) }
    static func != (_ lhs: MemberExpression, _ rhs: StringExpression) -> BooleanExpression { .neq(.string(.just(lhs), rhs)) }
    static func >  (_ lhs: MemberExpression, _ rhs: StringExpression) -> BooleanExpression { .gt(.string(.just(lhs), rhs)) }
    static func <  (_ lhs: MemberExpression, _ rhs: StringExpression) -> BooleanExpression { .lt(.string(.just(lhs), rhs)) }
    static func >= (_ lhs: MemberExpression, _ rhs: StringExpression) -> BooleanExpression { .ge(.string(.just(lhs), rhs)) }
    static func <= (_ lhs: MemberExpression, _ rhs: StringExpression) -> BooleanExpression { .le(.string(.just(lhs), rhs)) }

    static func == (_ lhs: StringExpression, _ rhs: MemberExpression) -> BooleanExpression { .eq(.string(lhs, .just(rhs))) }
    static func != (_ lhs: StringExpression, _ rhs: MemberExpression) -> BooleanExpression { .neq(.string(lhs, .just(rhs))) }
    static func >  (_ lhs: StringExpression, _ rhs: MemberExpression) -> BooleanExpression { .gt(.string(lhs, .just(rhs))) }
    static func <  (_ lhs: StringExpression, _ rhs: MemberExpression) -> BooleanExpression { .lt(.string(lhs, .just(rhs))) }
    static func >= (_ lhs: StringExpression, _ rhs: MemberExpression) -> BooleanExpression { .ge(.string(lhs, .just(rhs))) }
    static func <= (_ lhs: StringExpression, _ rhs: MemberExpression) -> BooleanExpression { .le(.string(lhs, .just(rhs))) }
}

public extension StringExpression {
    static func ++ (_ lhs: StringExpression, _ rhs: StringExpression) -> StringExpression { .concat(lhs, rhs) }

    static func ++ (_ lhs: MemberExpression, _ rhs: StringExpression) -> StringExpression { .concat(.just(lhs), rhs) }

    static func ++ (_ lhs: StringExpression, _ rhs: MemberExpression) -> StringExpression { .concat(lhs, .just(rhs)) }

    func lower()  -> StringExpression  { .lower(self) }
    func upper()  -> StringExpression  { .upper(self) }
    func length() -> NumericExpression { .length(self) }
}

public func atr(_ atr: AttributeName) -> MemberExpression { .atr(atr) }
public func val(_ val: Value) -> MemberExpression         { .val(val) }

extension MemberExpression: ExpressibleByBooleanLiteral { public init(booleanLiteral value: Bool)  { self = .val(Value(booleanLiteral: value)) } }
extension MemberExpression: ExpressibleByStringLiteral  { public init(stringLiteral value: String) { self = .val(Value(stringLiteral: value))  } }
extension MemberExpression: ExpressibleByIntegerLiteral { public init(integerLiteral value: Int)   { self = .val(Value(integerLiteral: value)) } }
extension MemberExpression: ExpressibleByFloatLiteral   { public init(floatLiteral value: Float)   { self = .val(Value(floatLiteral: value))   } }
extension MemberExpression: ExpressibleByNilLiteral     { public init(nilLiteral: ())              { self = .val(Value(nilLiteral: ()))        } }
