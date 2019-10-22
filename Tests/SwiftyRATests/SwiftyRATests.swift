import XCTest
@testable import SwiftyRA

final class SwiftyRATests: XCTestCase {
    func testProjection() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = r
            .project(attributes: ["id", "name", "hobby"])
            .project(attributes: ["id", "name"])

        print(s.tuples.value!)
    }

    func testSelection() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = r.select(from: ["age", "hobby"], where: { ctx in try ctx.age > 20 && ctx.hobby.hasValue })

        print(s.tuples.value!)
    }

    func testSelectionWithPredicate() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = r.select(age: .gt(.value(20)), hobby: .neq(.value(nil)))

        print(s.tuples.value!)
    }

    func testRenaming() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = r.rename(to: "identifier", from: "id")

        print(s.tuples.value!)
    }

    func testOrdering() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = r.order(by: ["hobby": .asc, "age": .asc])

        print(s.tuples.value!)
    }

    static var allTests = [
        ("testProjection", testProjection),
        ("testSelection",  testSelection),
        ("testSelectionWithPredicate", testSelectionWithPredicate),
        ("testRenaming",  testRenaming),
        ("testOrdering",  testOrdering),
    ]
}
