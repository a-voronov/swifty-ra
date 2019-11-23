// MARK: Query

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
public indirect enum Query {
    case just(Relation)

    case projection(ProjectionArguments, Query)
    // restriction
    case selection(BooleanExpression, Query)
    // TODO: allow renaming multiple attributes
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

// MARK: Sorting

extension Query {
    public enum SortingOrder: Hashable {
        case asc, desc
    }
}

// MARK: Joining

extension Query {
    public enum Join: Hashable {
        public enum Semi: Hashable {
            case right, left, anti
        }

        // if no common attributes = product
        case natural
        case theta(BooleanExpression)
        case semi(Semi)
    }
}

// MARK: Projection

extension Query {
    public typealias ProjectionArguments = [ProjectionArgument]

    public struct ProjectionArgument {
        public let attribute: AttributeName
        public let expression: Expression?

        public init(attribute: AttributeName, expression: Expression? = nil) {
            self.attribute = attribute
            self.expression = expression
        }
    }
}

// TODO: still thinking about it... doesn't feel right
//
//extension Query.ProjectionArgument: Hashable {
//    /// We don't care about expression if attributes are duplicated.
//    /// Thus uniqueness is defined by attributes only, which an be treated as a key, whereas expression is a value.
//    public static func == (_ lhs: Query.ProjectionArgument, _ rhs: Query.ProjectionArgument) -> Bool {
//        lhs.attribute == rhs.attribute
//    }
//
//    public func hash(into hasher: inout Hasher) {
//        attribute.hash(into: &hasher)
//    }
//}
