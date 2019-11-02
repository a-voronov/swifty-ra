/// When tuples can't be conformed to equatable, custom structs can :)
public struct Pair<L, R> {
    public let left: L
    public let right: R

    public var both: (left: L, right: R) { (left, right) }

    public init(_ l: L, _ r: R) {
        left = l
        right = r
    }
}

extension Pair: Equatable where L: Equatable, R: Equatable {}

extension Pair: Hashable where L: Hashable, R: Hashable {}
