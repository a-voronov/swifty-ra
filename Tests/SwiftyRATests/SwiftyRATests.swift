import XCTest
@testable import SwiftyRA

final class SwiftyRATests: XCTestCase {

    func testMisc() {
        let x: Value = 42
        let y: Value = "hello, world"
        let result = x + y

        print("❌ \(result)")

        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        print(r.header.value!["id"])
        print(r.id)
        print(r.age > 20 && r.hobby != nil)
        print(Query.Predicate.StringOperation.upper(.member(r.name)))
        print(val("id").debugDescription)

        print(Query.join(.theta(r.age > 20 && r.hobby != nil), .selection(r.age > 18, .relation(r)), .rename("years", "age", .relation(r))))
    }
    
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

        print(s)
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
        let s = r.select(where: r.age > 20 && r.hobby != nil)

        print(s)
    }

    func testSelectionDynamicCall() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = r.select(name: "Bob", age: 24)

        print(s)
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

        print(s)
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

        print(s)
    }

    func testOrderingDynamicCall() {
        let r = Relation(
            header: ["id": .required(.integer), "name": .required(.string), "age": .required(.integer), "hobby": .optional(.string)],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let s = r.order(by: ["hobby": .asc, "age": .asc])

        print(s)
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

        print(o)
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

        print(o)
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
        let o = r.subtract(s)

        print(o)
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

        print(o)
    }

    func testDivision() {
        let r = Relation(
            header: ["student": .required(.string), "task": .required(.string)],
            tuples: [
                ["Fred", "Database1"],
                ["Fred", "Database2"],
                ["Fred", "Compiler1"],
                ["Eugene", "Database1"],
                ["Eugene", "Compiler1"],
                ["Sarah", "Database1"],
                ["Sarah", "Database2"]
            ]
        )
        let s = Relation(
            header: ["task": .required(.string)],
            tuples: [
                ["Database1"],
                ["Database2"]
            ]
        )
        let o = r.divide(by: s)

        print(o)
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

        print(o)
    }

    func testThetaJoin() {
        let r = Relation(
            header: ["code": .required(.integer), "date": .required(.string), "officer": .required(.integer), "dept": .required(.integer), "registration": .required(.string)],
            tuples: [
                [143256, "25/10/1992", 567, 750, "5694 FR"],
                [987554, "26/10/1992", 456, 750, "5694 FR"],
                [987557, "26/10/1992", 456, 750, "6544 XY"],
                [630876, "15/10/1992", 456, 470, "6544 XY"],
                [539856, "12/10/1992", 567, 470, "6544 XY"]
            ]
        )
        let s = Relation(
            header: ["registration": .required(.string), "dept": .required(.integer), "owner": .required(.string)],
            tuples: [
                ["6544 XY", 750, "Cordon Edouard"],
                ["7122 HT", 750, "Cordon Edouard"],
                ["5694 FR", 750, "Latour Hortense"],
                ["6544 XY", 470, "Mimault Bernard"]
            ]
        )
        let o = r.join(with: s, on: r.officer > r.dept)

        print(o)
    }

    func testLeftSemiJoin() {
        let r = Relation(
            header: ["Name": .required(.string), "EmpId": .required(.integer), "DeptName": .required(.string)],
            tuples: [
                ["Harry", 3415, "Finance"],
                ["Sally", 2241, "Sales"],
                ["George", 3401, "Finance"],
                ["Harriet", 2202, "Production"]
            ]
        )
        let s = Relation(
            header: ["DeptName": .required(.string), "Manager": .required(.string)],
            tuples: [
                ["Sales", "Sally"],
                ["Production", "Harriet"]
            ]
        )
        let o = r.leftSemiJoin(with: s)

        print(o)
    }

    func testRightSemiJoin() {
        let r = Relation(
            header: ["Name": .required(.string), "EmpId": .required(.integer), "DeptName": .required(.string)],
            tuples: [
                ["Harry", 3415, "Finance"],
                ["Sally", 2241, "Sales"],
                ["George", 3401, "Finance"],
                ["Harriet", 2202, "Production"]
            ]
        )
        let s = Relation(
            header: ["DeptName": .required(.string), "Manager": .required(.string)],
            tuples: [
                ["Sales", "Sally"],
                ["Production", "Harriet"]
            ]
        )
        let o = r.rightSemiJoin(with: s)

        print(o)
    }

    func testAntiSemiJoin() {
        let r = Relation(
            header: ["Name": .required(.string), "EmpId": .required(.integer), "DeptName": .required(.string)],
            tuples: [
                ["Harry", 3415, "Finance"],
                ["Sally", 2241, "Sales"],
                ["George", 3401, "Finance"],
                ["Harriet", 2202, "Production"]
            ]
        )
        let s = Relation(
            header: ["DeptName": .required(.string), "Manager": .required(.string)],
            tuples: [
                ["Sales", "Sally"],
                ["Production", "Harriet"]
            ]
        )
        let o = r.antiSemiJoin(with: s)

        print(o)
    }

    static var allTests = [
        ("testMisc", testMisc),
        ("testProjection", testProjection),
        ("testSelection",  testSelection),
        ("testSelectionDynamicCall",  testSelectionDynamicCall),
        ("testRenaming",  testRenaming),
        ("testOrdering",  testOrdering),
        ("testOrderingDynamicCall", testOrderingDynamicCall),
        ("testIntersection", testIntersection),
        ("testUnion", testUnion),
        ("testSubtraction", testSubtraction),
        ("testProduct", testProduct),
        ("testDivision", testDivision),
        ("testNaturalJoin", testNaturalJoin),
        ("testThetaJoin", testThetaJoin),
        ("testLeftSemiJoin", testLeftSemiJoin),
        ("testRightSemiJoin", testRightSemiJoin),
        ("testAntiSemiJoin", testAntiSemiJoin),
    ]
}
