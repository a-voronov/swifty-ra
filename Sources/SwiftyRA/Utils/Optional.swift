func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    return a.flatMap { a in b.map { b in (a, b) } }
}

func zip<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
    return zip(a, b).flatMap { a, b in c.map { c in (a, b, c) } }
}

func zip<A, B, C, D>(_ a: A?, _ b: B?, _ c: C?, _ d: D?) -> (A, B, C, D)? {
    return zip(a, b, c).flatMap { a, b, c in d.map { d in (a, b, c, d) } }
}

extension Optional {
    func map<T>(_ keyPath: KeyPath<Wrapped, T>) -> T? {
        return map { $0[keyPath: keyPath] }
    }

    func flatMap<T>(_ keyPath: KeyPath<Wrapped, T?>) -> T? {
        return flatMap { $0[keyPath: keyPath] }
    }
}
