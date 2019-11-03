/// [Syntax Diagram.](https://dbis-uibk.github.io/relax/help.htm#relalg-relalgexpr)
///
/// Recursive query representation. Ends with provided relation.
///
/// ```
/// .join(.natural,
///     .projection(["id", "name"],
///         .relation(r)
///     ),
///     .relation(s)
/// )
/// ```
public indirect enum Query: Hashable {
    public enum SortingOrder: Hashable {
        case asc, desc
    }

    public enum Join: Hashable {
        public enum Semi: Hashable {
            case right, left, anti
        }

        // if no common attributes = product
        case natural
        case theta(Predicate)
        case semi(Semi)
    }

    case relation(Relation)

    case projection(Set<AttributeName>, Query)
    // restriction
    case selection(Predicate, Query)
    case rename(AttributeName, AttributeName, Query)
    case orderBy([Pair<AttributeName, SortingOrder>], Query)
    // case groupBy(???, Query) <- should implement it?

    case intersection(Query, Query)
    case union(Query, Query)
    // difference of l and r, relative complement of r in l
    case subtraction(Query, Query)
    // cross product, cross join, cartesian product
    case product(Query, Query)
    case division(Query, Query)
    case join(Join, Query, Query)
}
