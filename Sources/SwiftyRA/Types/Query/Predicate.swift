extension Query {
    public indirect enum Predicate: Hashable {
        /// Context containing values requested by attributes while performing selection query.
        /// Provides dynamic member access via property as well as via usual subscript by name.
        @dynamicMemberLookup
        public struct Context: Hashable {
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

        public enum Member: Hashable {
            case atr(AttributeName)
            case val(Value)
        }

        public enum Operators: Hashable {
            case any(Member, Member)
            case numbers(NumericOperation, NumericOperation)
            case strings(StringOperation, StringOperation)
        }

        public indirect enum NumericOperation: Hashable {
            case member(Member)

            case add(NumericOperation, NumericOperation)
            case sub(NumericOperation, NumericOperation)
            case mul(NumericOperation, NumericOperation)
            case div(NumericOperation, NumericOperation)
            case mod(NumericOperation, NumericOperation)

            case round(FloatingPointRoundingRule, NumericOperation)
            case length(StringOperation)
        }

        public indirect enum StringOperation: Hashable {
            case member(Member)

            case lower(StringOperation)
            case upper(StringOperation)
        }

        case member(Member)

        case and(Predicate, Predicate)
        case or(Predicate, Predicate)
        case not(Predicate)

        case eq(Operators)
        case neq(Operators)
        case gt(Operators)
        case lt(Operators)
        case ge(Operators)
        case le(Operators)
    }
}

// MARK: Utils

extension Query.Predicate {
    var attributes: Set<AttributeName> {
        switch self {
        case let .member(member): return member.attributes
        case let .and(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .or(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .not(p): return p.attributes
        case let .eq(op): return op.attributes
        case let .neq(op): return op.attributes
        case let .gt(op): return op.attributes
        case let .lt(op): return op.attributes
        case let .ge(op): return op.attributes
        case let .le(op): return op.attributes
        }
    }
}

extension Query.Predicate.Member {
    var attributes: Set<AttributeName> {
        switch self {
        case .atr(let a): return [a]
        case .val: return []
        }
    }
}

extension Query.Predicate.Operators {
    var attributes: Set<AttributeName> {
        switch self {
        case let .any(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .numbers(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .strings(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        }
    }
}

extension Query.Predicate.NumericOperation {
    var attributes: Set<AttributeName> {
        switch self {
        case let .member(member): return member.attributes
        case let .add(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .sub(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .mul(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .div(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .mod(lhs, rhs): return lhs.attributes.union(rhs.attributes)
        case let .round(_, op): return op.attributes
        case let .length(op): return op.attributes
        }
    }
}

extension Query.Predicate.StringOperation {
    var attributes: Set<AttributeName> {
        switch self {
        case let .member(member): return member.attributes
        case let .lower(op): return op.attributes
        case let .upper(op): return op.attributes
        }
    }
}
