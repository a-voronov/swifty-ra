/// Tuples is designed somehow similar to ordered set.
/// However combining operations do not preserve any order.
/// When creating and/or inserting tuples, if there're already such, their order will be kept original.
/// Some of initializers, transforming, combining and adding/removing methods are not public,
/// So that it's impossible to mess up tuples of different types from the outside.
/// You can access `array` and `set` properties to work with either representation.
public struct Tuples {
    public private(set) var array: [Tuple] = []
    public private(set) var set: Set<Tuple> = []

    // MARK: Creating Tuples

    public init(header: Header, tuples: [[AttributeName: Value]]) {
        let attributes = header.attributes
        tuples.forEach { tuple in
            guard tuple.isNotEmpty else {
                return
            }
            for attribute in attributes {
                let value = tuple[attribute.name, default: .none]
                guard value.isMatching(type: attribute.type) else {
                    return
                }
            }
            insert(Tuple(values: tuple))
        }
    }

    public init(header: Header, tuples: [[Value]]) {
        let attributes = header.attributes
        tuples.forEach { tuple in
            var valuesPerName: [AttributeName: Value] = [:]
            for (index, attribute) in attributes.enumerated() {
                let value = index < tuple.count ? tuple[index] : Value.none
                guard value.isMatching(type: attribute.type) else {
                    return
                }
                valuesPerName[attribute.name] = value
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
            array.append(newMember)
        }
        return (inserted, memberAfterInsert)
    }

    // MARK: Testing for Membership

    public func contains(_ element: Tuple) -> Bool {
        set.contains(element)
    }

    public var count: Int {
        array.count
    }

    public var isEmpty: Bool {
        array.isEmpty
    }

    // MARK: Accessing Elements

    public subscript(position: Int) -> Tuple? {
        position < array.count
            ? array[position]
            : nil
    }

    public var first: Tuple? {
        array.first
    }

    public var last: Tuple? {
        array.last
    }

    // MARK: Transforming Set

    public func forEach<E: Error>(_ body: (Tuple) -> Result<Void, E>) -> Result<Void, E> {
        for tuple in array {
            switch body(tuple) {
            case .success: continue
            case .failure(let error): return .failure(error)
            }
        }
        return .success()
    }

    public func forEach(_ body: (Tuple) -> Void) {
        safely { forEach { .success(body($0)) } }
    }

    public func filter<E: Error>(_ isIncluded: (Tuple) -> Result<Bool, E>) -> Result<Tuples, E> {
        var tuples = Tuples()
        for tuple in array {
            switch isIncluded(tuple) {
            case let .success(passed):
                if passed {
                    tuples.insert(tuple)
                }
            case let .failure(error):
                return .failure(error)
            }
        }
        return .success(tuples)
    }

    public func filter(_ isIncluded: (Tuple) -> Bool) -> Tuples {
        safely { filter { .success(isIncluded($0)) } }
    }

    public func sorted<E: Error>(by areInIncreasingOrder: (Tuple, Tuple) -> Result<Bool, E>) -> Result<Tuples, E> {
        var tuples = self
        return Result {
            try tuples.array.sort { lhs, rhs in
                try areInIncreasingOrder(lhs, rhs).get()
            }
            return tuples
        }
        .mapError { $0 as! E }
    }

    public func sorted(by areInIncreasingOrder: (Tuple, Tuple) -> Bool) -> Tuples {
        safely { sorted { .success(areInIncreasingOrder($0, $1)) } }
    }
}

// MARK: Transforming Tuples

extension Tuples {
    private init() {}

    private func safely<T>(_ f: () -> Result<T, Never>) -> T {
        f().only
    }

    func map<E: Error>(_ transform: (Tuple) -> Result<Tuple, E>) -> Result<Tuples, E> {
        var tuples = Tuples()
        for tuple in array {
            switch transform(tuple) {
            case let .success(newTuple): tuples.insert(newTuple)
            case let .failure(error): return .failure(error)
            }
        }
        return .success(tuples)
    }

    func map(_ transform: (Tuple) -> Tuple) -> Tuples {
        safely { map { .success(transform($0)) } }
    }

    func flatMap<E: Error>(_ transform: (Tuple) -> Result<Tuples, E>) -> Result<Tuples, E> {
        var tuples = Tuples()
        for tuple in array {
            switch transform(tuple) {
            case let .success(newTuples):
                newTuples.forEach { newTuple in
                    tuples.insert(newTuple)
                }
            case let .failure(error):
                return .failure(error)
            }
        }
        return .success(tuples)
    }

    func flatMap(_ transform: (Tuple) -> Tuples) -> Tuples {
        safely { flatMap { .success(transform($0)) } }
    }

    func compactMap<E: Error>(_ transform: (Tuple) -> Result<Tuple?, E>) -> Result<Tuples, E> {
        var tuples = Tuples()
        for tuple in array {
            switch transform(tuple) {
            case let .success(newTuple):
                if let newTuple = newTuple {
                    tuples.insert(newTuple)
                }
            case let .failure(error):
                return .failure(error)
            }
        }
        return .success(tuples)
    }

    func compactMap(_ transform: (Tuple) -> Tuple?) -> Tuples {
        safely { compactMap { .success(transform($0)) } }
    }
}

// MARK: Combining Tuples

extension Tuples {
    private init(_ elements: Set<Tuple>) {
        array = Array(elements)
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

// MARK: Equality & Hashing

extension Tuples: Equatable {
    public static func == (lhs: Tuples, rhs: Tuples) -> Bool {
        lhs.array == rhs.array
    }
}

extension Tuples: Hashable {
    public func hash(into hasher: inout Hasher) {
        array.hash(into: &hasher)
    }
}

// MARK: Debugging

extension Tuples: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Tuples[\n\t" + array.map(\.debugDescription).joined(separator: ",\n\t") + "\n]"
    }
}
