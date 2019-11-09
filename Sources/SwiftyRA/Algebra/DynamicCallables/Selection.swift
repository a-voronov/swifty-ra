@dynamicCallable
public struct Selection {
    let relation: Relation

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<AttributeName, Query.Predicate.Member>) -> Relation {
        let predicate: Query.Predicate = args.filter(\.key.isNotEmpty)
            .map { attributeName, member in atr(attributeName).eq(member) }
            .reduce(.member(true)) { acc, predicate in
                acc.and(predicate)
            }
        return relation.select(where: predicate)
    }
}
