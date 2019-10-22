/// [Syntax Diagram.](https://dbis-uibk.github.io/relax/help.htm#relalg-relalgexpr)
///
/// Recursive query representation. Ends with provided relation.
///
/// ```
/// .join(.leftOuter,
///     .projection(["id", "name"],
///         .relation(r)
///     ),
///     .relation(s)
/// )
/// ```
public indirect enum Query {
    public enum SortingOrder {
        case asc, desc
    }

    /// Context containing values requested by attributes while performing selection query.
    /// Provides dynamic member access via property as well as via usual subscript by name.
    @dynamicMemberLookup
    public struct SelectionContext {
        public let values: [AttributeName: Value]

        public subscript(name: AttributeName) -> Value? {
            values[name]
        }

        public subscript(name: AttributeName, default value: Value) -> Value {
            values[name, default: value]
        }

        public subscript(dynamicMember member: AttributeName) -> Value {
            self[member, default: .none]
        }
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
    case selection(Set<AttributeName>, (SelectionContext) throws -> Bool, Query)
    case rename(AttributeName, AttributeName, Query)
    case orderBy(KeyValuePairs<AttributeName, SortingOrder>, Query)
//    //case groupBy(???, Query)
//
//    case intersection(Query, Query)
//    case union(Query, Query)
//    case division(Query, Query)
//    case substraction(Query, Query)
//    case crossProduct(Query, Query)
//    case join(Join, Query, Query)
}
