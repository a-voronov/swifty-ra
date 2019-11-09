// MARK: Value

extension Value: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .boolean(value): return "\(value)"
        case let .string(value):  return "\"\(value)\""
        case let .integer(value): return "\(value)"
        case let .float(value):   return "\(value)"
        case .none: return "nil"
        }
    }
}

// MARK: Attributes

extension ValueType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .boolean: return "Bool"
        case .string:  return "String"
        case .integer: return "Int"
        case .float:   return "Float"
        }
    }
}

extension AttributeType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .required(valueType): return valueType.debugDescription
        case let .optional(valueType): return valueType.debugDescription + "?"
        }
    }
}

extension Attribute: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Attribute(\(name): \(type))"
    }
}

// MARK: Predicate

extension Query.Predicate.Member: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .atr(attribute): return attribute
        case let .val(value):     return value.debugDescription
        }
    }
}

extension Query.Predicate.NumericOperation: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .member(m):       return m.debugDescription
        case let .add(lhs, rhs):   return "(\(lhs) + \(rhs))"
        case let .sub(lhs, rhs):   return "(\(lhs) - \(rhs))"
        case let .mul(lhs, rhs):   return "\(lhs) * \(rhs)"
        case let .div(lhs, rhs):   return "\(lhs) / \(rhs)"
        case let .mod(lhs, rhs):   return "(\(lhs) % \(rhs))"
        case let .round(rule, op): return "round(\(rule): \(op))"
        case let .length(op):      return "length(\(op))"
        }
    }
}

extension Query.Predicate.StringOperation: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .member(m): return m.debugDescription
        case let .lower(op): return "lower(\(op))"
        case let .upper(op): return "upper(\(op))"
        }
    }
}

extension Query.Predicate.Operators {
    fileprivate var lhsDebugDescription: String {
        switch self {
        case let .any(lhs, _):     return lhs.debugDescription
        case let .numbers(lhs, _): return lhs.debugDescription
        case let .strings(lhs, _): return lhs.debugDescription
        }
    }

    fileprivate var rhsDebugDescription: String {
        switch self {
        case let .any(_, rhs):     return rhs.debugDescription
        case let .numbers(_, rhs): return rhs.debugDescription
        case let .strings(_, rhs): return rhs.debugDescription
        }
    }
}

extension Query.Predicate: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .member(m):     return m.debugDescription
        case let .and(lhs, rhs): return "\(lhs) and \(rhs)"
        case let .or(lhs, rhs):  return "\(lhs) or \(rhs)"
        case let .not(p):        return "not \(p)"
        case let .eq(op):        return "\(op.lhsDebugDescription) = \(op.rhsDebugDescription)"
        case let .neq(op):       return "\(op.lhsDebugDescription) ≠ \(op.rhsDebugDescription)"
        case let .gt(op):        return "\(op.lhsDebugDescription) > \(op.rhsDebugDescription)"
        case let .lt(op):        return "\(op.lhsDebugDescription) < \(op.rhsDebugDescription)"
        case let .ge(op):        return "\(op.lhsDebugDescription) ≥ \(op.rhsDebugDescription)"
        case let .le(op):        return "\(op.lhsDebugDescription) ≤ \(op.rhsDebugDescription)"
        }
    }
}

// MARK: Query

extension Query: CustomDebugStringConvertible {
    public var debugDescription: String {
        ""
    }
}

// MARK: Header

extension Header: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Header(\n\t" + attributes.map { $0.name + ": " + $0.type.debugDescription }.joined(separator: ",\n\t") + "\n)"
    }
}

// MARK: Tuple

extension Tuple: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Tuple(\n\t" + values.map { $0.key + ": " + $0.value.debugDescription }.joined(separator: ",\n\t") + "\n)"
    }
}

// MARK: Tuples

extension Tuples: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Tuples[\n\t" + array.map(\.debugDescription).joined(separator: ",\n\t") + "\n]"
    }
}

// MARK: Relation

extension Relation: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch state {
        case let .success(value):
            return "✅ Relation:\n" + ConsoleTable(header: value.header, tuples: value.tuples).toString()
        case let .failure(error):
            return "❌ Relation:\n" + error.debugDescription
        }
    }
}
