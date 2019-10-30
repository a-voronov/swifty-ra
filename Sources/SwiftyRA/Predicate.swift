// MARK: - Predicate

extension Query {
    public indirect enum Predicate {
        /// Context containing values requested by attributes while performing selection query.
        /// Provides dynamic member access via property as well as via usual subscript by name.
        @dynamicMemberLookup
        public struct Context {
            private let values: [AttributeName: Value]

            init(values: [AttributeName: Value]) {
                self.values = values
            }

            public subscript(name: AttributeName) -> Value? {
                values[name]
            }

            public subscript(name: AttributeName, default value: Value) -> Value {
                values[name, default: value]
            }

            public subscript(dynamicMember member: AttributeName) -> Value {
                self[member, default: .none]
            }
        }

        public enum Member {
            case atr(AttributeName)
            case val(Value)
        }

        public enum Operators {
            case any(Member, Member)
            case numbers(NumericOperation, NumericOperation)
            case strings(StringOperation, StringOperation)
        }

        public indirect enum NumericOperation {
            case member(Member)

            case add(NumericOperation, NumericOperation)
            case sub(NumericOperation, NumericOperation)
            case mul(NumericOperation, NumericOperation)
            case div(NumericOperation, NumericOperation)
            case mod(NumericOperation, NumericOperation)

            case round(FloatingPointRoundingRule, NumericOperation)
            case length(StringOperation)
        }

        public indirect enum StringOperation {
            case member(Member)

            case lower(StringOperation)
            case upper(StringOperation)
        }

        case member(Member)

        case and(Predicate, Predicate)
        case or(Predicate, Predicate)
        case not(Predicate)

        case eq(Operators)
        case gt(Operators)
        case lt(Operators)
        case ge(Operators)
        case le(Operators)
    }
}

// MARK: - Evaluation

private func apply<T, U>(_ block: @escaping (T) throws -> U) -> (T) -> Result<U, Query.Predicate.Errors> {
    return { value in
        do {
            return .success(try block(value))
        } catch let error as Value.Errors {
            return .failure(.value(error))
        } catch {
            return .failure(error as! Query.Predicate.Errors)
        }
    }
}

public extension Query.Predicate {
    enum Errors: Error, Equatable {
        case value(Value.Errors)
        case unknownAttributes(Set<AttributeName>)
    }

    private func applyBinary(
        _ lhs: Query.Predicate,
        _ rhs: Query.Predicate,
        _ ctx: Query.Predicate.Context,
        _ op: @escaping (Bool, Bool) -> Bool
    ) -> Result<Bool, Query.Predicate.Errors> {
        zip(lhs.eval(ctx), rhs.eval(ctx)).mapError(\.value).map(op)
    }

    private func toBool(_ value: Value) -> Result<Bool, Query.Predicate.Errors> {
        value.boolean.map(Result.success) ?? .failure(.value(.incompatible(value)))
    }

    func eval(_ ctx: Query.Predicate.Context) -> Result<Bool, Query.Predicate.Errors> {
        switch self {
        case let .member(member): return member.eval(ctx).flatMap(toBool)

        case let .and(lhs, rhs): return applyBinary(lhs, rhs, ctx) { $0 && $1 }
        case let .or(lhs, rhs):  return applyBinary(lhs, rhs, ctx) { $0 || $1 }

        case let .not(op): return op.eval(ctx).map(!)
        case let .eq(ops): return ops.eval(ctx).map(==)
        case let .gt(ops): return ops.eval(ctx).flatMap(apply(>))
        case let .lt(ops): return ops.eval(ctx).flatMap(apply(<))
        case let .ge(ops): return ops.eval(ctx).flatMap(apply(>=))
        case let .le(ops): return ops.eval(ctx).flatMap(apply(<=))
        }
    }
}

public extension Query.Predicate.Operators {
    func eval(_ ctx: Query.Predicate.Context) -> Result<(Value, Value), Query.Predicate.Errors> {
        switch self {
        case let .any(lhs, rhs):     return zip(lhs.eval(ctx), rhs.eval(ctx)).mapError(\.value)
        case let .numbers(lhs, rhs): return zip(lhs.eval(ctx), rhs.eval(ctx)).mapError(\.value)
        case let .strings(lhs, rhs): return zip(lhs.eval(ctx), rhs.eval(ctx)).mapError(\.value)
        }
    }
}

public extension Query.Predicate.NumericOperation {
    private func applyBinary(
        _ lhs: Query.Predicate.NumericOperation,
        _ rhs: Query.Predicate.NumericOperation,
        _ ctx: Query.Predicate.Context,
        _ op: @escaping (Value, Value) throws -> Value
    ) -> Result<Value, Query.Predicate.Errors> {
        zip(lhs.eval(ctx), rhs.eval(ctx)).mapError(\.value).flatMap(apply(op))
    }

    func eval(_ ctx: Query.Predicate.Context) -> Result<Value, Query.Predicate.Errors> {
        switch self {
        case let .member(member): return member.eval(ctx)

        case let .add(lhs, rhs): return applyBinary(lhs, rhs, ctx, +)
        case let .sub(lhs, rhs): return applyBinary(lhs, rhs, ctx, -)
        case let .mul(lhs, rhs): return applyBinary(lhs, rhs, ctx, *)
        case let .div(lhs, rhs): return applyBinary(lhs, rhs, ctx, /)
        case let .mod(lhs, rhs): return applyBinary(lhs, rhs, ctx, %)

        case let .round(rule, op): return op.eval(ctx).flatMap(apply { try $0.rounded(rule) })
        case let .length(op): return op.eval(ctx).flatMap(apply { try $0.length() })
        }
    }
}

public extension Query.Predicate.StringOperation {
    func eval(_ ctx: Query.Predicate.Context) -> Result<Value, Query.Predicate.Errors> {
        switch self {
        case let .member(member): return member.eval(ctx)

        case let .lower(op): return op.eval(ctx).flatMap(apply { try $0.lower() })
        case let .upper(op): return op.eval(ctx).flatMap(apply { try $0.upper() })
        }
    }
}

public extension Query.Predicate.Member {
    func eval(_ ctx: Query.Predicate.Context) -> Result<Value, Query.Predicate.Errors> {
        switch self {
        case let .atr(a): return ctx[a].map(Result.success) ?? .failure(.unknownAttributes([a]))
        case let .val(v): return .success(v)
        }
    }
}

// MARK: - DSL

// TODO: support operators (+, -, *, /, %, ==, !=, !, >, <, >=, <=, &&, ||)

public extension Query.Predicate.Member {
    func and(_ another: Query.Predicate) -> Query.Predicate { .and(.member(self), another) }
    func or(_ another: Query.Predicate) -> Query.Predicate  { .or(.member(self), another) }
    func not() -> Query.Predicate                           { .not(.member(self)) }

    func and(_ another: Query.Predicate.Member) -> Query.Predicate { .and(.member(self), .member(another)) }
    func or(_ another: Query.Predicate.Member) -> Query.Predicate  { .or(.member(self), .member(another)) }

    func eq(_ another: Query.Predicate.Member) -> Query.Predicate { .eq(.any(self, another)) }
    func gt(_ another: Query.Predicate.Member) -> Query.Predicate { .gt(.any(self, another)) }
    func lt(_ another: Query.Predicate.Member) -> Query.Predicate { .lt(.any(self, another)) }
    func ge(_ another: Query.Predicate.Member) -> Query.Predicate { .ge(.any(self, another)) }
    func le(_ another: Query.Predicate.Member) -> Query.Predicate { .le(.any(self, another)) }

    func eq(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .eq(.numbers(.member(self), another)) }
    func gt(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .gt(.numbers(.member(self), another)) }
    func lt(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .lt(.numbers(.member(self), another)) }
    func ge(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .ge(.numbers(.member(self), another)) }
    func le(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .le(.numbers(.member(self), another)) }

    func eq(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .eq(.strings(.member(self), another)) }
    func gt(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .gt(.strings(.member(self), another)) }
    func lt(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .lt(.strings(.member(self), another)) }
    func ge(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .ge(.strings(.member(self), another)) }
    func le(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .le(.strings(.member(self), another)) }

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

    func eq(_ another: Query.Predicate.Member) -> Query.Predicate { .eq(.numbers(self, .member(another))) }
    func gt(_ another: Query.Predicate.Member) -> Query.Predicate { .gt(.numbers(self, .member(another))) }
    func lt(_ another: Query.Predicate.Member) -> Query.Predicate { .lt(.numbers(self, .member(another))) }
    func ge(_ another: Query.Predicate.Member) -> Query.Predicate { .ge(.numbers(self, .member(another))) }
    func le(_ another: Query.Predicate.Member) -> Query.Predicate { .le(.numbers(self, .member(another))) }

    func eq(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .eq(.numbers(self, another)) }
    func gt(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .gt(.numbers(self, another)) }
    func lt(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .lt(.numbers(self, another)) }
    func ge(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .ge(.numbers(self, another)) }
    func le(_ another: Query.Predicate.NumericOperation) -> Query.Predicate { .le(.numbers(self, another)) }

    static func == (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.eq(rhs) }
    static func == (lhs: Query.Predicate.NumericOperation, rhs: Query.Predicate.NumericOperation) -> Query.Predicate { lhs.eq(rhs) }

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

    func eq(_ another: Query.Predicate.Member) -> Query.Predicate { .eq(.strings(self, .member(another))) }
    func gt(_ another: Query.Predicate.Member) -> Query.Predicate { .gt(.strings(self, .member(another))) }
    func lt(_ another: Query.Predicate.Member) -> Query.Predicate { .lt(.strings(self, .member(another))) }
    func ge(_ another: Query.Predicate.Member) -> Query.Predicate { .ge(.strings(self, .member(another))) }
    func le(_ another: Query.Predicate.Member) -> Query.Predicate { .le(.strings(self, .member(another))) }

    func eq(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .eq(.strings(self, another)) }
    func gt(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .gt(.strings(self, another)) }
    func lt(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .lt(.strings(self, another)) }
    func ge(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .ge(.strings(self, another)) }
    func le(_ another: Query.Predicate.StringOperation) -> Query.Predicate { .le(.strings(self, another)) }

    static func == (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.Member) -> Query.Predicate { lhs.eq(rhs) }
    static func == (lhs: Query.Predicate.StringOperation, rhs: Query.Predicate.StringOperation) -> Query.Predicate { lhs.eq(rhs) }

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
