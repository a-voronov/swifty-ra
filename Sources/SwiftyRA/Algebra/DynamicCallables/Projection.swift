@dynamicCallable
public struct Projection {
    let relation: Relation

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<AttributeName, Expression>) -> Relation {
        let projectionArgs: Query.ProjectionArguments = args.map { arg in
            if arg.key.isEmpty {
                if case let .atr(attribute)? = arg.value as? MemberExpression {
                    return Query.ProjectionArgument(attribute: attribute, expression: arg.value)
                }
            }
            return Query.ProjectionArgument(attribute: arg.key, expression: arg.value)
        }
        return relation.project(projectionArgs)
    }
}
