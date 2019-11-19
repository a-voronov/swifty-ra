@dynamicCallable
public struct Projection {
    let relation: Relation

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<AttributeName, AnyExpression>) -> Relation {
        return relation.project(args.map(Query.ProjectionArgument.init))
    }
}
