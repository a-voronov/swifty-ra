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
        let s = r.order(hobby: .asc, age: .asc)

        print(s.tuples.value!)
    }

    func testOrderingWithPredicate() {
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

    func testIntersection() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21],
                [2, "Bobby", 24, "cycling"],
                [3, "Carol", 19, nil]
            ]
        )
        let o = r.intersect(with: s)

        print(o.tuples.value!)
    }

    func testUnion() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21],
                [2, "Bobby", 24, "cycling"],
                [3, "Carol", 19, nil]
            ]
        )
        let o = r.union(with: s)

        print(o.tuples.value!)
    }

    func testSubtraction() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 22],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 28, nil]
            ]
        )
        let o = r.subtract(from: s)

        print(o.tuples.value!)
    }

    func testProduct() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = Relation(
            header: ["class": .required(.string), "roomNumber": .required(.integer)],
            tuples: [
                ["math", 128],
                ["biology", 301],
                ["chemistry", 9],
                ["physics", 48],
                ["english", 403]
            ]
        )
        let o = r.product(with: s)

        print(o.tuples.value!)
    }

    func testDivision() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21],
                [2, "Bobby", 24, "cycling"],
                [3, "Carol", 19, nil]
            ]
        )
        let o = r.divide(by: s)

        print(o.tuples.value!)
    }

    func testNaturalJoin() {
        let r = Relation(
            header: ["code": .required(.integer), "date": .required(.string), "officer": .required(.integer), "dept": .required(.integer), "registration": .required(.string)],
            tuples: [
                [143256, "25/10/1992", 567, 75, "5694 FR"],
                [987554, "26/10/1992", 456, 75, "5694 FR"],
                [987557, "26/10/1992", 456, 75, "6544 XY"],
                [630876, "15/10/1992", 456, 47, "6544 XY"],
                [539856, "12/10/1992", 567, 47, "6544 XY"]
            ]
        )
        let s = Relation(
            header: ["registration": .required(.string), "dept": .required(.integer), "owner": .required(.string)],
            tuples: [
                ["6544 XY", 75, "Cordon Edouard"],
                ["7122 HT", 75, "Cordon Edouard"],
                ["5694 FR", 75, "Latour Hortense"],
                ["6544 XY", 47, "Mimault Bernard"]
            ]
        )
        let o = r.join(with: s)

        print(o.tuples.value!)
    }

    static var allTests = [
        ("testProjection", testProjection),
        ("testSelection",  testSelection),
        ("testSelectionWithPredicate", testSelectionWithPredicate),
        ("testRenaming",  testRenaming),
        ("testOrdering",  testOrdering),
        ("testOrderingWithPredicate", testOrderingWithPredicate),
        ("testIntersection", testIntersection),
        ("testUnion", testUnion),
        ("testSubtraction", testSubtraction),
        ("testProduct", testProduct),
        ("testDivision", testDivision),
        ("testNaturalJoin", testNaturalJoin),
    ]
}
