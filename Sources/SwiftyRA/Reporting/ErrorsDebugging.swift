// MARK: Value

extension Value.Errors: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .mismatch(values, expectedTypes):
            let valuesDescription = values.isOne
                ? "Value \(values)"
                : "Values \(values.array.map(\.debugDescription).joined(separator: " and "))"
            let typesDescription = expectedTypes.isOne
                ? "\(expectedTypes) type"
                : "either \(expectedTypes.array.map(\.debugDescription).joined(separator: " or ")) type"
            return "\(valuesDescription) should be of \(typesDescription)."
        case let .incompatible(lhs, rhs):
            return "Values \(lhs) and \(rhs) should be of the same type."
        }
    }
}

// MARK: Predicate

extension Query.Predicate.Errors: CustomDebugStringConvertible {
    public var debugDescription: String {
        ""
    }
}

// MARK: Query

extension Query.Errors: CustomDebugStringConvertible {
    public var debugDescription: String {
        ""
    }
}

// MARK: Header

extension Header.Errors: CustomDebugStringConvertible {
    public var debugDescription: String {
        ""
    }
}

// MARK: Relation

extension Relation.Errors: CustomDebugStringConvertible {
    public var debugDescription: String {
        ""
    }
}
