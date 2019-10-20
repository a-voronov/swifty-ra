/// [Syntax Diagram.](https://dbis-uibk.github.io/relax/help.htm#relalg-relalgexpr)
///
///```
///.join(.leftOuter,
///    .projection(["id", "name"],
///        .relation(r)
///    ),
///    .relation(s)
///)
///```
public indirect enum Query {
    public enum Order {
        case asc, desc
    }

//    public enum Join {
//        case theta
//        case natural
//        case leftOuter
//        case rightOuter
//        case fullOuter
//        case leftSemi
//        case rightSemi
//        case antiSemi
//    }

    case relation(Relation)

    case projection(Set<AttributeName>, Query)
    case selection(Set<AttributeName>, ([AttributeName: Value]) throws -> Bool, Query)
    case rename(AttributeName, AttributeName, Query)
    case orderBy([(AttributeName, Order)], Query)
//    //case groupBy(???, Query)
//
//    case intersection(Query, Query)
//    case union(Query, Query)
//    case division(Query, Query)
//    case substraction(Query, Query)
//    case crossProduct(Query, Query)
//    case join(Join, Query, Query)
}
