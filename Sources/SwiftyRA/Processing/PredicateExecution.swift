private func apply<T, U>(_ block: @escaping (T) -> Value.Throws<U>) -> (T) -> Query.Predicate.Throws<U> {
    return { value in
        block(value).mapError(Query.Predicate.Errors.value)
    }
}

public extension Query.Predicate {
    private func applyBinary(
        _ lhs: Query.Predicate,
        _ rhs: Query.Predicate,
        _ ctx: Query.Predicate.Context,
        _ op: @escaping (Bool, Bool) -> Bool
    ) -> Query.Predicate.Throws<Bool> {
        zip(lhs.execute(with: ctx), rhs.execute(with: ctx)).mapError(\.value).map(op)
    }

    private func toBool(_ value: Value) -> Query.Predicate.Throws<Bool> {
        Query.Predicate.Throws(
            value: value.boolean,
            error: .value(.mismatch(.one(value), .one(.boolean)))
        )
    }

    func execute(with ctx: Query.Predicate.Context) -> Query.Predicate.Throws<Bool> {
        switch self {
        case let .member(member): return member.execute(with: ctx).flatMap(toBool)

        case let .and(lhs, rhs): return applyBinary(lhs, rhs, ctx) { $0 && $1 }
        case let .or(lhs, rhs):  return applyBinary(lhs, rhs, ctx) { $0 || $1 }
        case let .not(p):  return p.execute(with: ctx).map(!)

        case let .eq(ops):  return ops.execute(with: ctx).map(==)
        case let .neq(ops): return ops.execute(with: ctx).map(!=)
        case let .gt(ops):  return ops.execute(with: ctx).flatMap(apply(>))
        case let .lt(ops):  return ops.execute(with: ctx).flatMap(apply(<))
        case let .ge(ops):  return ops.execute(with: ctx).flatMap(apply(>=))
        case let .le(ops):  return ops.execute(with: ctx).flatMap(apply(<=))
        }
    }
}

public extension Query.Predicate.Operators {
    func execute(with ctx: Query.Predicate.Context) -> Query.Predicate.Throws<(Value, Value)> {
        switch self {
        case let .any(lhs, rhs):     return zip(lhs.execute(with: ctx), rhs.execute(with: ctx)).mapError(\.value)
        case let .numbers(lhs, rhs): return zip(lhs.execute(with: ctx), rhs.execute(with: ctx)).mapError(\.value)
        case let .strings(lhs, rhs): return zip(lhs.execute(with: ctx), rhs.execute(with: ctx)).mapError(\.value)
        }
    }
}

public extension Query.Predicate.NumericOperation {
    private func applyBinary(
        _ lhs: Query.Predicate.NumericOperation,
        _ rhs: Query.Predicate.NumericOperation,
        _ ctx: Query.Predicate.Context,
        _ op: @escaping (Value, Value) -> Value.Throws<Value>
    ) -> Query.Predicate.Throws<Value> {
        zip(lhs.execute(with: ctx), rhs.execute(with: ctx)).mapError(\.value).flatMap(apply(op))
    }

    func execute(with ctx: Query.Predicate.Context) -> Query.Predicate.Throws<Value> {
        switch self {
        case let .member(member): return member.execute(with: ctx)

        case let .add(lhs, rhs): return applyBinary(lhs, rhs, ctx, +)
        case let .sub(lhs, rhs): return applyBinary(lhs, rhs, ctx, -)
        case let .mul(lhs, rhs): return applyBinary(lhs, rhs, ctx, *)
        case let .div(lhs, rhs): return applyBinary(lhs, rhs, ctx, /)
        case let .mod(lhs, rhs): return applyBinary(lhs, rhs, ctx, %)

        case let .round(rule, op): return op.execute(with: ctx).flatMap(apply { $0.rounded(rule) })
        case let .length(op): return op.execute(with: ctx).flatMap(apply { $0.length() })
        }
    }
}

public extension Query.Predicate.StringOperation {
    func execute(with ctx: Query.Predicate.Context) -> Query.Predicate.Throws<Value> {
        switch self {
        case let .member(member): return member.execute(with: ctx)

        case let .lower(op): return op.execute(with: ctx).flatMap(apply { $0.lower() })
        case let .upper(op): return op.execute(with: ctx).flatMap(apply { $0.upper() })
        }
    }
}

public extension Query.Predicate.Member {
    func execute(with ctx: Query.Predicate.Context) -> Query.Predicate.Throws<Value> {
        switch self {
        case let .atr(a): return Query.Predicate.Throws(value: ctx[a], error: .unknownAttribute(a))
        case let .val(v): return .success(v)
        }
    }
}
