// MARK: Value

public extension Value {
    typealias Throws<T> = Result<T, Value.Errors>

    enum Errors: Error, Hashable {
        case mismatch(OneOrMore<Value>, OneOrMore<ValueType>)
        case incompatible(Value, Value)
    }
}

// MARK: Expression

public extension Expression {
    typealias Throws<T> = Result<T, ExpressionErrors>
}

public enum ExpressionErrors: Error, Hashable {
    case value(Value.Errors)
    case unknownAttribute(AttributeName)
}

// MARK: Query

public extension Query {
    enum Errors: Error, Hashable {
        /// same attributes were listed several times
        case duplicatedAttributes(OneOrMore<AttributeName>)
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
        /// could not infer type
        case typeInferring(OneOrMore<AttributeName>)
        /// error while evaluating predicate
        case expression(ExpressionErrors)
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

