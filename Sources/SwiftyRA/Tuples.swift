/// Tuples is designed somehow similar to ordered set.
/// However combining operations do not preserve any order.
/// When creating and/or inserting tuples, if there're already such, their order will be kept original.
/// Some of initializers, transforming, combining and adding/removing methods are not public,
/// So that it's impossible to mess up tuples of different types from the outside.
/// You can access `array` and `set` properties to work with either representation.
public struct Tuples {
    private var ary: Array<Tuple> = []
    public var array: [Tuple] { ary }
    public private(set) var set: Set<Tuple> = []

    // MARK: Creating Tuples

    public init(attributes: [Attribute], tuples: [[Value]]) {
        for tuple in tuples {
            var valuesPerName: [AttributeName: Value] = [:]
            for (index, attribute) in attributes.enumerated() {
                let value = index < tuple.count ? tuple[index] : Value.none
                if value.isMatching(type: attribute.type) {
                    valuesPerName[attribute.name] = value
                } else {
                    valuesPerName = [:]
                    break
                }
            }
            if valuesPerName.isNotEmpty {
                insert(Tuple(values: valuesPerName))
            }
        }
    }

    @discardableResult
    private mutating func insert(_ newMember: Tuple) -> (inserted: Bool, memberAfterInsert: Tuple) {
        let (inserted, memberAfterInsert) = set.insert(newMember)
        if inserted {
            ary.append(newMember)
        }
        return (inserted, memberAfterInsert)
    }

    // MARK: Testing for Membership

    public func contains(_ element: Tuple) -> Bool {
        set.contains(element)
    }

    public var count: Int {
        ary.count
    }

    public var isEmpty: Bool {
        ary.isEmpty
    }

    // MARK: Accessing Elements

    public subscript(position: Int) -> Tuple? {
        position < ary.count
            ? ary[position]
            : nil
    }

    public var first: Tuple? {
        ary.first
    }

    public var last: Tuple? {
        ary.last
    }

    // MARK: Transforming Set

    public func forEach(_ body: (Tuple) throws -> Void) rethrows {
        try ary.forEach(body)
    }

    public func filter(_ isIncluded: (Tuple) throws -> Bool) rethrows -> Tuples {
        var ts = Tuples()
        for element in ary {
            if try isIncluded(element) {
                ts.insert(element)
            }
        }
        return ts
    }

    public func filter<E: Error>(_ isIncluded: (Tuple) -> Result<Bool, E>) -> Result<Tuples, E> {
        var ts = Tuples()
        for element in ary {
            switch isIncluded(element) {
            case let .success(passed):
                if passed {
                    ts.insert(element)
                }
            case let .failure(error):
                return .failure(error)
            }
        }
        return .success(ts)
    }

    public func sorted(by areInIncreasingOrder: (Tuple, Tuple) throws -> Bool) rethrows -> Tuples {
        try updating(self) { try $0.sort(by: areInIncreasingOrder) }
    }

    mutating func sort(by areInIncreasingOrder: (Tuple, Tuple) throws -> Bool) rethrows {
        try ary.sort(by: areInIncreasingOrder)
    }
}

// MARK: Transforming Tuples

extension Tuples {
    private init() {}

    func map(_ transform: (Tuple) throws -> Tuple) rethrows -> Tuples {
        var ts = Tuples()
        for element in ary {
            ts.insert(try transform(element))
        }
        return ts
    }

    func flatMap(_ transform: (Tuple) throws -> Tuples) rethrows -> Tuples {
        var ts = Tuples()
        for element in ary {
            try transform(element).forEach { t in
                ts.insert(t)
            }
        }
        return ts
    }

    func compactMap(_ transform: (Tuple) throws -> Tuple?) rethrows -> Tuples {
        var ts = Tuples()
        for element in ary {
            if let e = try transform(element) {
                ts.insert(e)
            }
        }
        return ts
    }
}

extension Tuples {
    func map<E: Error>(_ transform: (Tuple) -> Result<Tuple, E>) -> Result<Tuples, E> {
        var tuples = Tuples()
        for element in ary {
            switch transform(element) {
            case let .success(tuple): tuples.insert(tuple)
            case let .failure(error): return .failure(error)
            }
        }
        return .success(tuples)
    }

    func flatMap<E: Error>(_ transform: (Tuple) -> Result<Tuples, E>) -> Result<Tuples, E> {
        var tuples = Tuples()
        for element in ary {
            switch transform(element) {
            case let .success(ts):
                ts.forEach { tuple in
                    tuples.insert(tuple)
                }
            case let .failure(error):
                return .failure(error)
            }
        }
        return .success(tuples)
    }

    func compactMap<E: Error>(_ transform: (Tuple) -> Result<Tuple?, E>) -> Result<Tuples, E> {
        var tuples = Tuples()
        for element in ary {
            switch transform(element) {
            case let .success(tuple):
                if let tuple = tuple {
                    tuples.insert(tuple)
                }
            case let .failure(error):
                return .failure(error)
            }
        }
        return .success(tuples)
    }
}

// MARK: Combining Tuples

extension Tuples {
    private init(_ elements: Set<Tuple>) {
        ary = Array(elements)
        set = elements
    }

    func union(_ other: Tuples) -> Tuples {
        Tuples(set.union(other.set))
    }

    func intersection(_ other: Tuples) -> Tuples {
        Tuples(set.intersection(other.set))
    }

    func subtracting(_ other: Tuples) -> Tuples {
        Tuples(set.subtracting(other.set))
    }
}

// MARK: Tuples Equality

extension Tuples: Equatable {
    public static func == (lhs: Tuples, rhs: Tuples) -> Bool {
        lhs.ary == rhs.ary
    }
}

// MARK: Tuples Hashing

extension Tuples: Hashable {
    public func hash(into hasher: inout Hasher) {
        ary.hash(into: &hasher)
    }
}
