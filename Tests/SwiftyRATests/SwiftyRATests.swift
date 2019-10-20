import XCTest
@testable import SwiftyRA

final class SwiftyRATests: XCTestCase {
    func testProjection() {
        let r = try! Relation(
            header: [("id", .required(.integer)), ("name", .required(.string)), ("age", .required(.integer)), ("hobby", .optional(.string))],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let q = Query.projection(["id", "name"], .projection(["id", "name", "hobby"], .relation(r)))
        let s = try! QueryProcessor().execute(query: q)

        print(s.tuples)
    }

    func testSelection() {
        let r = try! Relation(
            header: [("id", .required(.integer)), ("name", .required(.string)), ("age", .required(.integer)), ("hobby", .optional(.string))],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let q = Query.selection(["age", "hobby"], { ctx in try ctx["age"]! > 20 && ctx["hobby"]?.hasValue == true }, .relation(r))
//        let q = Query.selection(.and(.gt(.value("age", 20)), .not(.eq(.value("hobby", nil)))), .relation(r))
        let s = try! QueryProcessor().execute(query: q)

        print(s.tuples)
    }

    func testRenaming() {
        let r = try! Relation(
            header: [("id", .required(.integer)), ("name", .required(.string)), ("age", .required(.integer)), ("hobby", .optional(.string))],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let q = Query.rename("identifier", "id", .relation(r))
        let s = try! QueryProcessor().execute(query: q)

        print(s.tuples)
    }

    func testOrdering() {
        let r = try! Relation(
            header: [("id", .required(.integer)), ("name", .required(.string)), ("age", .required(.integer)), ("hobby", .optional(.string))],
            tuples: [
                [1, "Alice", 21, nil],
                [2, "Bob",   24, "cycling"],
                [3, "Carol", 19]
            ]
        )
        let q = Query.orderBy([("hobby", .asc), ("age", .asc)], .relation(r))
        let s = try! QueryProcessor().execute(query: q)

        print(s.tuples)
    }

    static var allTests = [
        ("testProjection", testProjection),
        ("testSelection",  testSelection),
        ("testRenaming",  testRenaming),
        ("testOrdering",  testOrdering)
    ]
}
