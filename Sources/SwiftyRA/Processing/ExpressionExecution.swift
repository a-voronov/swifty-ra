// MARK: - Expression

//// TODO: Expression protocol which is Hashable = pain
//public protocol Expression: Hashable {
//    var attributes: Set<AttributeName> { get }
//
//    func execute(with context: ExpressionContext) -> Throws<Value>
//}
//
//public struct AnyExpression: Expression, Hashable {
//    public static func == (lhs: AnyExpression, rhs: AnyExpression) -> Bool {
//        lhs._eq(rhs)
//    }
//
//    public func hash(into hasher: inout Hasher) {
//        _hash(&hasher)
//    }
//
//    private let _attributes: () -> Set<AttributeName>
//    private let _execute: (ExpressionContext) -> Throws<Value>
//    private let _eq: (AnyExpression) -> Bool
//    private let _hash: (inout Hasher) -> Void
//
//    public var attributes: Set<AttributeName> {
//        _attributes()
//    }
//
//    public func execute(with context: ExpressionContext) -> Throws<Value> {
//        _execute(context)
//    }
//
//    init<E: Expression>(expression: E) {
//        _attributes = { expression.attributes }
//        _execute = expression.execute
//        _eq = { expression == $0 }
//        _hash = expression.hash
//    }
//}

// MARK: Context

@dynamicMemberLookup
public struct ExpressionContext: Hashable {
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

// MARK: - Any

extension AnyExpression {
    public var attributes: Set<AttributeName> {
        switch self {
        case let .member(exp):  return exp.attributes
        case let .boolean(exp): return exp.attributes
        case let .numeric(exp): return exp.attributes
        case let .string(exp):  return exp.attributes
        }
    }

    public func execute(with context: ExpressionContext) -> Throws<Value> {
        switch self {
        case let .member(exp):  return exp.execute(with: context)
        case let .boolean(exp): return exp.execute(with: context)
        case let .numeric(exp): return exp.execute(with: context)
        case let .string(exp):  return exp.execute(with: context)
        }
    }
}

// MARK: - Member

extension MemberExpression {
    public var attributes: Set<AttributeName> {
        switch self {
        case let .atr(a): return [a]
        case .val: return []
        }
    }

    public func execute(with context: ExpressionContext) -> Throws<Value> {
        switch self {
        case let .atr(a): return Throws(value: context[a], error: .unknownAttribute(a))
        case let .val(v): return .success(v)
        }
    }
}

// MARK: Boolean

extension BooleanExpression {
    public var attributes: Set<AttributeName> {
        switch self {
        case let .just(member):  return member.attributes
        case let .and(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .or(lhs, rhs):  return lhs.attributes.union(rhs.attributes)

        case let .not(exp): return exp.attributes
        case let .eq(ops):  return ops.attributes
        case let .neq(ops): return ops.attributes
        case let .gt(ops):  return ops.attributes
        case let .lt(ops):  return ops.attributes
        case let .ge(ops):  return ops.attributes
        case let .le(ops):  return ops.attributes
        }
    }

    public func execute(with context: ExpressionContext) -> Throws<Value> {
        switch self {
        case let .just(member): return member.execute(with: context)

        case let .and(lhs, rhs): return applyBinary(lhs, rhs, context, &&)
        case let .or(lhs, rhs):  return applyBinary(lhs, rhs, context, ||)
        case let .not(exp):      return applyUnary(exp, context, !)

        case let .eq(ops):  return applyOperands(ops, context, ==)
        case let .neq(ops): return applyOperands(ops, context, !=)
        case let .gt(ops):  return applyOperands(ops, context, >)
        case let .lt(ops):  return applyOperands(ops, context, <)
        case let .ge(ops):  return applyOperands(ops, context, >=)
        case let .le(ops):  return applyOperands(ops, context, <=)
        }
    }

    func executeAndCast(with context: ExpressionContext) -> Throws<Bool> {
        execute(with: context).flatMap { $0.asBoolean.mapError(ExpressionErrors.value) }
    }

    private func applyUnary(
        _ exp: BooleanExpression,
        _ ctx: ExpressionContext,
        _ op: @escaping (Value) -> Value.Throws<Bool>
    ) -> Throws<Value> {
        exp.execute(with: ctx).flatMap(apply(op)).map(Value.boolean)
    }

    private func applyBinary(
        _ lhs: BooleanExpression,
        _ rhs: BooleanExpression,
        _ ctx: ExpressionContext,
        _ op: @escaping (Value, Value) -> Value.Throws<Bool>
    ) -> Throws<Value> {
        zip(lhs.execute(with: ctx), rhs.execute(with: ctx)).flatMap(apply(op)).map(Value.boolean)
    }

    private func applyOperands(
        _ ops: BooleanExpression.Operands,
        _ ctx: ExpressionContext,
        _ op: @escaping (Value, Value) -> Value.Throws<Bool>
    ) -> Throws<Value> {
        ops.execute(with: ctx).flatMap(apply(op)).map(Value.boolean)
    }
}

extension BooleanExpression.Operands {
    var attributes: Set<AttributeName> {
        switch self {
        case let .any(lhs, rhs):     return lhs.attributes.union(rhs.attributes)
        case let .numeric(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .string(lhs, rhs):  return lhs.attributes.union(rhs.attributes)
        case let .boolean(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        }
    }

    func execute(with context: ExpressionContext) -> Result<(Value, Value), ExpressionErrors> {
        switch self {
        case let .any(lhs, rhs):     return zip(lhs.execute(with: context), rhs.execute(with: context))
        case let .numeric(lhs, rhs): return zip(lhs.execute(with: context), rhs.execute(with: context))
        case let .string(lhs, rhs):  return zip(lhs.execute(with: context), rhs.execute(with: context))
        case let .boolean(lhs, rhs): return zip(lhs.execute(with: context), rhs.execute(with: context))
        }
    }
}

// MARK: Numeric

extension NumericExpression {
    public var attributes: Set<AttributeName> {
        switch self {
        case let .just(member):  return member.attributes
        case let .add(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .sub(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .mul(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .div(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .mod(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .round(_, exp): return exp.attributes
        case let .length(exp):   return exp.attributes
        }
    }

    public func execute(with context: ExpressionContext) -> Throws<Value> {
        switch self {
        case let .just(member): return member.execute(with: context)

        case let .add(lhs, rhs): return applyBinary(lhs, rhs, context, +)
        case let .sub(lhs, rhs): return applyBinary(lhs, rhs, context, -)
        case let .mul(lhs, rhs): return applyBinary(lhs, rhs, context, *)
        case let .div(lhs, rhs): return applyBinary(lhs, rhs, context, /)
        case let .mod(lhs, rhs): return applyBinary(lhs, rhs, context, %)

        case let .round(rule, exp): return exp.execute(with: context).flatMap(apply { $0.rounded(rule) })
        case let .length(exp):      return exp.execute(with: context).flatMap(apply { $0.length() })
        }
    }

    private func applyBinary(
        _ lhs: NumericExpression,
        _ rhs: NumericExpression,
        _ ctx: ExpressionContext,
        _ op: @escaping (Value, Value) -> Value.Throws<Value>
    ) -> Throws<Value> {
        zip(lhs.execute(with: ctx), rhs.execute(with: ctx)).flatMap(apply(op))
    }
}

// MARK: String

extension StringExpression {
    public var attributes: Set<AttributeName> {
        switch self {
        case let .just(member):     return member.attributes
        case let .lower(exp):       return exp.attributes
        case let .upper(exp):       return exp.attributes
        case let .concat(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        }
    }

    public func execute(with context: ExpressionContext) -> Throws<Value> {
        switch self {
        case let .just(member):     return member.execute(with: context)

        case let .lower(exp):       return exp.execute(with: context).flatMap(apply { $0.lower() })
        case let .upper(exp):       return exp.execute(with: context).flatMap(apply { $0.upper() })
        case let .concat(lhs, rhs): return applyBinary(lhs, rhs, context, ++)
        }
    }

    private func applyBinary(
        _ lhs: StringExpression,
        _ rhs: StringExpression,
        _ ctx: ExpressionContext,
        _ op: @escaping (Value, Value) -> Value.Throws<Value>
    ) -> Throws<Value> {
        zip(lhs.execute(with: ctx), rhs.execute(with: ctx)).flatMap(apply(op))
    }
}

// MARK: - Utils

private func apply<T, U>(_ block: @escaping (T) -> Value.Throws<U>) -> (T) -> Result<U, ExpressionErrors> {
    return { value in
        block(value).mapError(ExpressionErrors.value)
    }
}
