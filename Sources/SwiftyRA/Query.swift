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
indirect enum Query {
    enum Order {
        case asc, desc
    }

    enum Join {
        case theta
        case natural
        case leftOuter
        case rightOuter
        case fullOuter
        case leftSemi
        case rightSemi
        case antiSemi
    }

    case relation(Relation)

    // unary operations
    case projection([AttributeName], Query)
    case selection([(AttributeName, (Value) -> Bool)], Query)
    case rename(AttributeName, AttributeName, Query)
    case orderBy([(AttributeName, Order)], Query)
    //case groupBy(???, Query)

    // binary operations
    case intersection(Query, Query)
    case union(Query, Query)
    case division(Query, Query)
    case substraction(Query, Query)
    case crossProduct(Query, Query)
    case join(Join, Query, Query)
}
