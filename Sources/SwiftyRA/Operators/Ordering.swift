@dynamicCallable
public struct Ordering {
    let relation: Relation

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<AttributeName, Query.SortingOrder>) -> Relation {
        relation.order(by: args)
    }
}
