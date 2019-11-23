// MARK: Member

public enum MemberExpression: Hashable {
    case atr(AttributeName)
    case val(Value)
}

// MARK: Boolean

public indirect enum BooleanExpression: Hashable {
    public enum Operands: Hashable {
        case any(MemberExpression, MemberExpression)
        case boolean(BooleanExpression, BooleanExpression)
        case numeric(NumericExpression, NumericExpression)
        case string(StringExpression, StringExpression)
    }

    case just(MemberExpression)

    case and(BooleanExpression, BooleanExpression)
    case or(BooleanExpression, BooleanExpression)
    case not(BooleanExpression)

    case eq(Operands)
    case neq(Operands)
    case gt(Operands)
    case lt(Operands)
    case ge(Operands)
    case le(Operands)
}

// MARK: Numeric

public indirect enum NumericExpression: Hashable {
    case just(MemberExpression)

    case add(NumericExpression, NumericExpression)
    case sub(NumericExpression, NumericExpression)
    case mul(NumericExpression, NumericExpression)
    case div(NumericExpression, NumericExpression)
    case mod(NumericExpression, NumericExpression)

    case round(FloatingPointRoundingRule, NumericExpression)
    case length(StringExpression)
}

// MARK: String

public indirect enum StringExpression: Hashable {
    case just(MemberExpression)

    case lower(StringExpression)
    case upper(StringExpression)
    case concat(StringExpression, StringExpression)
}
