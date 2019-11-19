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

// MARK: Expressions

extension MemberExpression: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .atr(attribute): return attribute
        case let .val(value):     return value.debugDescription
        }
    }
}

extension NumericExpression: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .just(member):     return member.debugDescription
        case let .add(lhs, rhs):    return "(\(lhs) + \(rhs))"
        case let .sub(lhs, rhs):    return "(\(lhs) - \(rhs))"
        case let .mul(lhs, rhs):    return "\(lhs) * \(rhs)"
        case let .div(lhs, rhs):    return "\(lhs) / \(rhs)"
        case let .mod(lhs, rhs):    return "(\(lhs) % \(rhs))"
        case let .round(rule, exp): return "round(\(rule): \(exp))"
        case let .length(exp):      return "length(\(exp))"
        }
    }
}

extension StringExpression: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .just(member):     return member.debugDescription
        case let .lower(exp):       return "lower(\(exp))"
        case let .upper(exp):       return "upper(\(exp))"
        case let .concat(lhs, rhs): return "\(lhs) ++ \(rhs)"
        }
    }
}

extension BooleanExpression.Operands {
    fileprivate var lhsDebugDescription: String {
        switch self {
        case let .any(lhs, _):     return lhs.debugDescription
        case let .numeric(lhs, _): return lhs.debugDescription
        case let .string(lhs, _):  return lhs.debugDescription
        case let .boolean(lhs, _): return lhs.debugDescription
        }
    }

    fileprivate var rhsDebugDescription: String {
        switch self {
        case let .any(_, rhs):     return rhs.debugDescription
        case let .numeric(_, rhs): return rhs.debugDescription
        case let .string(_, rhs):  return rhs.debugDescription
        case let .boolean(_, rhs): return rhs.debugDescription
        }
    }
}

extension BooleanExpression: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .just(member):  return member.debugDescription
        case let .and(lhs, rhs): return "\(lhs) and \(rhs)"
        case let .or(lhs, rhs):  return "\(lhs) or \(rhs)"
        case let .not(exp):      return "not \(exp)"
        case let .eq(exp):       return "\(exp.lhsDebugDescription) = \(exp.rhsDebugDescription)"
        case let .neq(exp):      return "\(exp.lhsDebugDescription) ≠ \(exp.rhsDebugDescription)"
        case let .gt(exp):       return "\(exp.lhsDebugDescription) > \(exp.rhsDebugDescription)"
        case let .lt(exp):       return "\(exp.lhsDebugDescription) < \(exp.rhsDebugDescription)"
        case let .ge(exp):       return "\(exp.lhsDebugDescription) ≥ \(exp.rhsDebugDescription)"
        case let .le(exp):       return "\(exp.lhsDebugDescription) ≤ \(exp.rhsDebugDescription)"
        }
    }
}

// MARK: Query

extension Query.SortingOrder: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .asc: return "asc"
        case .desc: return "desc"
        }
    }
}

extension Query: CustomDebugStringConvertible {
    private func description(_ relNum: (Relation) -> Int) -> String {
        switch self {
        case let .just(r):
            let number = relNum(r)
            let numberDescription = number > 0 ? "\(number)" : ""
            return "R\(numberDescription)"
        case let .projection(args, query):
            return "π TODO: ( \(query.description(relNum)) )"
//            return "π \(attributes.joined(separator: ", ")) ( \(query.description(relNum)) )"
        case let .selection(predicate, query):
            return "σ \(predicate) ( \(query.description(relNum)) )"
        case let .rename(to, from, query):
            return "ρ \(to) ← \(from) ( \(query.description(relNum)) )"
        case let .orderBy(attributes, query):
            return "τ \(attributes.map { "\($0.left) \($0.right)" }.joined(separator: ", ")) ( \(query.description(relNum)) )"
        case let .intersection(lhs, rhs):
            return "( \(lhs.description(relNum)) ) ∩ ( \(rhs.description(relNum)) )"
        case let .union(lhs, rhs):
            return "( \(lhs.description(relNum)) ) ∪ ( \(rhs.description(relNum)) )"
        case let .subtraction(lhs, rhs):
            return "( \(lhs.description(relNum)) ) - ( \(rhs.description(relNum)) )"
        case let .product(lhs, rhs):
            return "( \(lhs.description(relNum)) ) ⨯ ( \(rhs.description(relNum)) )"
        case let .division(lhs, rhs):
            return "( \(lhs.description(relNum)) ) ÷ ( \(rhs.description(relNum)) )"
        case let .join(.natural, lhs, rhs):
            return "( \(lhs.description(relNum)) ) ⋈ ( \(rhs.description(relNum)) )"
        case let .join(.theta(predicate), lhs, rhs):
            return "( \(lhs.description(relNum)) ) ⋈ \(predicate) ( \(rhs.description(relNum)) )"
        case let .join(.semi(.left), lhs, rhs):
            return "( \(lhs.description(relNum)) ) ⋉ ( \(rhs.description(relNum)) )"
        case let .join(.semi(.right), lhs, rhs):
            return "( \(lhs.description(relNum)) ) ⋊ ( \(rhs.description(relNum)) )"
        case let .join(.semi(.anti), lhs, rhs):
            return "( \(lhs.description(relNum)) ) ▷ ( \(rhs.description(relNum)) )"
        }
    }

    public var debugDescription: String {
        var cache: [Int: Int] = [:]
        var relNum = 0

        return description { r in
            // still not sure about this solution to identify Relation struct, but it works for now
            let addr = unsafeBitCast(r, to: Int.self)
            if let seen = cache[addr] {
                return seen
            } else {
                let num = relNum
                cache[addr] = num
                relNum += 1
                return num
            }
        }
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
        let tupleDescription = { (tuple: Tuple) in
            "(" + tuple.values.map { $0.key + ": " + $0.value.debugDescription }.joined(separator: ", ") + ")"
        }
        return "Tuples[\n\t" + array.map(tupleDescription).joined(separator: ",\n\t") + "\n]"
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
