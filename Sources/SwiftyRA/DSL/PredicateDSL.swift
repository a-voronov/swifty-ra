public extension Query.Predicate.Member {
    func and(_ another: Query.Predicate) -> Query.Predicate { .and(.member(self), another) }
    func or(_ another: Query.Predicate) -> Query.Predicate  { .or(.member(self), another) }
    func not() -> Query.Predicate                           { .not(.member(self)) }

    func and(_ another: Query.Predicate.Member) -> Query.Predicate { .and(.member(self), .member(another)) }
    func or(_ another: Query.Predicate.Member) -> Query.Predicate  { .or(.member(self), .member(another)) }

    func eq(_ another: Query.Predicate.Member) -> Query.Predicate  { .eq(.any(self, another)) }
    func neq(_ another: Query.Predicate.Member) -> Query.Predicate { .neq(.any(self, another)) }
    func gt(_ another: Query.Predicate.Member) -> Query.Predicate  { .gt(.any(self, another)) }
    func lt(_ another: Query.Predicate.Member) -> Query.Predicate  { .lt(.any(self, another)) }
    func ge(_ another: Query.Predicate.Member) -> Query.Predicate  { .ge(.any(self, another)) }
    func le(_ another: Query.Predicate.Member) -> Query.Predicate  { .le(.any(self, another)) }

    func eq(_ another: Query.Predicate.NumericOperation) -> Query.Predicate  { .eq(.numbers(.member(self), another)) }
    func neq(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .neq(.numbers(.member(self), another)) }
    func gt(_ another: Query.Predicate.NumericOperation) -> Query.Predicate  { .gt(.numbers(.member(self), another)) }
    func lt(_ another: Query.Predicate.NumericOperation) -> Query.Predicate  { .lt(.numbers(.member(self), another)) }
    func ge(_ another: Query.Predicate.NumericOperation) -> Query.Predicate  { .ge(.numbers(.member(self), another)) }
    func le(_ another: Query.Predicate.NumericOperation) -> Query.Predicate  { .le(.numbers(.member(self), another)) }

    func eq(_ another: Query.Predicate.StringOperation) -> Query.Predicate  { .eq(.strings(.member(self), another)) }
    func neq(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .neq(.strings(.member(self), another)) }
    func gt(_ another: Query.Predicate.StringOperation) -> Query.Predicate  { .gt(.strings(.member(self), another)) }
    func lt(_ another: Query.Predicate.StringOperation) -> Query.Predicate  { .lt(.strings(.member(self), another)) }
    func ge(_ another: Query.Predicate.StringOperation) -> Query.Predicate  { .ge(.strings(.member(self), another)) }
    func le(_ another: Query.Predicate.StringOperation) -> Query.Predicate  { .le(.strings(.member(self), another)) }

    func add(_ another: Query.Predicate.Member) -> Query.Predicate.NumericOperation { .add(.member(self), .member(another)) }
    func sub(_ another: Query.Predicate.Member) -> Query.Predicate.NumericOperation { .sub(.member(self), .member(another)) }
    func mul(_ another: Query.Predicate.Member) -> Query.Predicate.NumericOperation { .mul(.member(self), .member(another)) }
    func div(_ another: Query.Predicate.Member) -> Query.Predicate.NumericOperation { .div(.member(self), .member(another)) }
    func mod(_ another: Query.Predicate.Member) -> Query.Predicate.NumericOperation { .mod(.member(self), .member(another)) }

    func add(_ another: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { .add(.member(self), another) }
    func sub(_ another: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { .sub(.member(self), another) }
    func mul(_ another: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { .mul(.member(self), another) }
    func div(_ another: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { .div(.member(self), another) }
    func mod(_ another: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { .mod(.member(self), another) }

    func length() -> Query.Predicate.NumericOperation { .length(.member(self)) }
    func round(_ rule: FloatingPointRoundingRule) -> Query.Predicate.NumericOperation { .round(rule, .member(self)) }

    func lower() -> Query.Predicate.StringOperation { .lower(.member(self)) }
    func upper() -> Query.Predicate.StringOperation { .upper(.member(self)) }
}

public extension Query.Predicate.Member {
    static func && (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.and(rhs) }
    static func && (lhs: Query.Predicate.Member, rhs: Query.Predicate) -> Query.Predicate { lhs.and(rhs) }

    static func || (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.or(rhs) }
    static func || (lhs: Query.Predicate.Member, rhs: Query.Predicate) -> Query.Predicate { lhs.or(rhs) }

    static prefix func ! (a: Query.Predicate.Member) -> Query.Predicate { a.not() }

    static func == (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.eq(rhs) }
    static func == (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.eq(rhs) }
    static func == (lhs: Query.Predicate.Member, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.eq(rhs) }

    static func != (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.neq(rhs) }
    static func != (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.neq(rhs) }
    static func != (lhs: Query.Predicate.Member, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.neq(rhs) }

    static func > (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.gt(rhs) }
    static func > (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.gt(rhs) }
    static func > (lhs: Query.Predicate.Member, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.gt(rhs) }

    static func < (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.lt(rhs) }
    static func < (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.lt(rhs) }
    static func < (lhs: Query.Predicate.Member, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.lt(rhs) }

    static func >= (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.ge(rhs) }
    static func >= (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.ge(rhs) }
    static func >= (lhs: Query.Predicate.Member, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.ge(rhs) }

    static func <= (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.le(rhs) }
    static func <= (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.le(rhs) }
    static func <= (lhs: Query.Predicate.Member, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.le(rhs) }

    static func + (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate.NumericOperation { lhs.add(rhs) }
    static func + (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { lhs.add(rhs) }

    static func - (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate.NumericOperation { lhs.sub(rhs) }
    static func - (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { lhs.sub(rhs) }

    static func * (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate.NumericOperation { lhs.mul(rhs) }
    static func * (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { lhs.mul(rhs) }

    static func / (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate.NumericOperation { lhs.div(rhs) }
    static func / (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { lhs.div(rhs) }

    static func % (lhs: Query.Predicate.Member, rhs: Query.Predicate.Member) -> Query.Predicate.NumericOperation { lhs.mod(rhs) }
    static func % (lhs: Query.Predicate.Member, rhs: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { lhs.mod(rhs) }
}

public extension Query.Predicate.NumericOperation {
    func add(_ another: Query.Predicate.Member) -> Query.Predicate.NumericOperation { .add(self, .member(another)) }
    func sub(_ another: Query.Predicate.Member) -> Query.Predicate.NumericOperation { .sub(self, .member(another)) }
    func mul(_ another: Query.Predicate.Member) -> Query.Predicate.NumericOperation { .mul(self, .member(another)) }
    func div(_ another: Query.Predicate.Member) -> Query.Predicate.NumericOperation { .div(self, .member(another)) }
    func mod(_ another: Query.Predicate.Member) -> Query.Predicate.NumericOperation { .mod(self, .member(another)) }

    func add(_ another: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { .add(self, another) }
    func sub(_ another: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { .sub(self, another) }
    func mul(_ another: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { .mul(self, another) }
    func div(_ another: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { .div(self, another) }
    func mod(_ another: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { .mod(self, another) }

    func round(_ rule: FloatingPointRoundingRule) -> Query.Predicate.NumericOperation { .round(rule, self) }

    func eq(_ another: Query.Predicate.Member) -> Query.Predicate  { .eq(.numbers(self, .member(another))) }
    func neq(_ another: Query.Predicate.Member) -> Query.Predicate { .neq(.numbers(self, .member(another))) }
    func gt(_ another: Query.Predicate.Member) -> Query.Predicate  { .gt(.numbers(self, .member(another))) }
    func lt(_ another: Query.Predicate.Member) -> Query.Predicate  { .lt(.numbers(self, .member(another))) }
    func ge(_ another: Query.Predicate.Member) -> Query.Predicate  { .ge(.numbers(self, .member(another))) }
    func le(_ another: Query.Predicate.Member) -> Query.Predicate  { .le(.numbers(self, .member(another))) }

    func eq(_ another: Query.Predicate.NumericOperation) -> Query.Predicate  { .eq(.numbers(self, another)) }
    func neq(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .neq(.numbers(self, another)) }
    func gt(_ another: Query.Predicate.NumericOperation) -> Query.Predicate  { .gt(.numbers(self, another)) }
    func lt(_ another: Query.Predicate.NumericOperation) -> Query.Predicate  { .lt(.numbers(self, another)) }
    func ge(_ another: Query.Predicate.NumericOperation) -> Query.Predicate  { .ge(.numbers(self, another)) }
    func le(_ another: Query.Predicate.NumericOperation) -> Query.Predicate  { .le(.numbers(self, another)) }

    static func == (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.eq(rhs) }
    static func == (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.eq(rhs) }

    static func != (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.neq(rhs) }
    static func != (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.neq(rhs) }

    static func > (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.gt(rhs) }
    static func > (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.gt(rhs) }

    static func < (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.lt(rhs) }
    static func < (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.lt(rhs) }

    static func >= (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.ge(rhs) }
    static func >= (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.ge(rhs) }

    static func <= (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.le(rhs) }
    static func <= (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.le(rhs) }

    static func + (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate.NumericOperation { lhs.add(rhs) }
    static func + (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { lhs.add(rhs) }

    static func - (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate.NumericOperation { lhs.sub(rhs) }
    static func - (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { lhs.sub(rhs) }

    static func * (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate.NumericOperation { lhs.mul(rhs) }
    static func * (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { lhs.mul(rhs) }

    static func / (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate.NumericOperation { lhs.div(rhs) }
    static func / (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { lhs.div(rhs) }

    static func % (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate.NumericOperation { lhs.mod(rhs) }
    static func % (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate.NumericOperation { lhs.mod(rhs) }
}

public extension Query.Predicate.StringOperation {
    func lower() -> Query.Predicate.StringOperation { .lower(self) }
    func upper() -> Query.Predicate.StringOperation { .upper(self) }

    func length() -> Query.Predicate.NumericOperation { .length(self) }

    func eq(_ another: Query.Predicate.Member) -> Query.Predicate  { .eq(.strings(self, .member(another))) }
    func neq(_ another: Query.Predicate.Member) -> Query.Predicate { .neq(.strings(self, .member(another))) }
    func gt(_ another: Query.Predicate.Member) -> Query.Predicate  { .gt(.strings(self, .member(another))) }
    func lt(_ another: Query.Predicate.Member) -> Query.Predicate  { .lt(.strings(self, .member(another))) }
    func ge(_ another: Query.Predicate.Member) -> Query.Predicate  { .ge(.strings(self, .member(another))) }
    func le(_ another: Query.Predicate.Member) -> Query.Predicate  { .le(.strings(self, .member(another))) }

    func eq(_ another: Query.Predicate.StringOperation) -> Query.Predicate  { .eq(.strings(self, another)) }
    func neq(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .neq(.strings(self, another)) }
    func gt(_ another: Query.Predicate.StringOperation) -> Query.Predicate  { .gt(.strings(self, another)) }
    func lt(_ another: Query.Predicate.StringOperation) -> Query.Predicate  { .lt(.strings(self, another)) }
    func ge(_ another: Query.Predicate.StringOperation) -> Query.Predicate  { .ge(.strings(self, another)) }
    func le(_ another: Query.Predicate.StringOperation) -> Query.Predicate  { .le(.strings(self, another)) }

    static func == (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.eq(rhs) }
    static func == (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.eq(rhs) }

    static func != (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.neq(rhs) }
    static func != (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.neq(rhs) }

    static func > (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.gt(rhs) }
    static func > (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.gt(rhs) }

    static func < (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.lt(rhs) }
    static func < (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.lt(rhs) }

    static func >= (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.ge(rhs) }
    static func >= (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.ge(rhs) }

    static func <= (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.le(rhs) }
    static func <= (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.le(rhs) }
}

public extension Query.Predicate {
    func and(_ another: Query.Predicate.Member) -> Query.Predicate { .and(self, .member(another)) }
    func or(_ another: Query.Predicate.Member) -> Query.Predicate  { .or(self, .member(another)) }

    func and(_ another: Query.Predicate) -> Query.Predicate { .and(self, another) }
    func or(_ another: Query.Predicate) -> Query.Predicate  { .or(self, another) }
    func not() -> Query.Predicate                           { .not(self) }

    static func && (lhs: Query.Predicate, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.and(rhs) }
    static func && (lhs: Query.Predicate, rhs: Query.Predicate) -> Query.Predicate { lhs.and(rhs) }

    static func || (lhs: Query.Predicate, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.or(rhs) }
    static func || (lhs: Query.Predicate, rhs: Query.Predicate) -> Query.Predicate { lhs.or(rhs) }

    static prefix func ! (a: Query.Predicate) -> Query.Predicate { a.not() }
}

public func atr(_ atr: AttributeName) -> Query.Predicate.Member { .atr(atr) }
public func val(_ val: Value) -> Query.Predicate.Member         { .val(val) }

extension Query.Predicate.Member: ExpressibleByBooleanLiteral { public init(booleanLiteral value: Bool)  { self = .val(Value(booleanLiteral: value)) } }
extension Query.Predicate.Member: ExpressibleByStringLiteral  { public init(stringLiteral value: String) { self = .val(Value(stringLiteral: value))  } }
extension Query.Predicate.Member: ExpressibleByIntegerLiteral { public init(integerLiteral value: Int)   { self = .val(Value(integerLiteral: value)) } }
extension Query.Predicate.Member: ExpressibleByFloatLiteral   { public init(floatLiteral value: Float)   { self = .val(Value(floatLiteral: value))   } }
extension Query.Predicate.Member: ExpressibleByNilLiteral     { public init(nilLiteral: ())              { self = .val(Value(nilLiteral: ()))        } }
