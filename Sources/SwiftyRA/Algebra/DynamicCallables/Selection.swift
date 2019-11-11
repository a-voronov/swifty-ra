@dynamicCallable
public struct Selection {
    let relation: Relation

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<AttributeName, MemberExpression>) -> Relation {
        let predicate: BooleanExpression = args
            .map { attributeName, member in
                attributeName.isEmpty
                    ? .just(member)
                    : atr(attributeName) == member
            }
            .reduce(.just(true)) { acc, predicate in
                acc && predicate
            }
        return relation.select(where: predicate)
    }
}
