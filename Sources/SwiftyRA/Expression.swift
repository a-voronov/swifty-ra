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
indirect enum Expression {
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
    case projection([AttributeName], Expression)
    case selection([(AttributeName, (Value) -> Bool)], Expression)
    case rename(AttributeName, AttributeName, Expression)
    case orderBy([(AttributeName, Order)], Expression)
    //case groupBy(???, Expression)

    // binary operations
    case intersection(Expression, Expression)
    case union(Expression, Expression)
    case division(Expression, Expression)
    case substraction(Expression, Expression)
    case crossProduct(Expression, Expression)
    case join(Join, Expression, Expression)
}
