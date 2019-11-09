/// Collection isNotEmpty
extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }
}

extension Collection {
    func decompose() -> (head: Element, tail: [Element])? {
        first.map { head in
            (head: head, tail: Array(dropFirst()))
        }
    }
}
