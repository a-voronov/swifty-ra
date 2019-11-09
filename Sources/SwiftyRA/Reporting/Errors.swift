// MARK: Value

public extension Value {
    typealias Throws<T> = Result<T, Value.Errors>

    enum Errors: Error, Hashable {
        case mismatch(OneOrMore<Value>, OneOrMore<ValueType>)
        case incompatible(Value, Value)
    }
}

// MARK: Predicate

public extension Query.Predicate {
    typealias Throws<T> = Result<T, Query.Predicate.Errors>

    enum Errors: Error, Hashable {
        case value(Value.Errors)
        case unknownAttribute(AttributeName)
    }
}

// MARK: Query

public extension Query {
    enum Errors: Error, Hashable {
        /// no such attributes
        case unknownAttributes(OneOrMore<AttributeName>)
        /// same name, different types
        case incompatibleAttributes(OneOrMore<Pair<Attribute, Attribute>>)
        /// should be equal
        case attributesNotUnionCompatible(OneOrMore<Attribute>, OneOrMore<Attribute>)
        /// should not share common attributes
        case attributesNotDisjointed(OneOrMore<Attribute>, OneOrMore<Attribute>)
        /// should contain all attributes from another relation
        case attributesNotSupersetToAnother(OneOrMore<Attribute>, OneOrMore<Attribute>)
        /// error while evaluating predicate
        case predicate(Query.Predicate.Errors)
    }
}

// MARK: Header

public extension Header {
    typealias Throws<T> = Result<T, Errors>

    enum Errors: Error, Hashable {
        case empty
        case duplicates(OneOrMore<AttributeName>)
    }
}

// MARK: Relation

public extension Relation {
    typealias Throws<T> = Result<T, Errors>

    enum Errors: Error, Hashable {
        case header(Header.Errors)
        case value(Value.Errors)
        case query(Query.Errors)
    }
}
