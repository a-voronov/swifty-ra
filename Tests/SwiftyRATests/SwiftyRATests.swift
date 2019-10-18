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
        let q = Query.selection({ t in t["age"]!.integer! > 20 && t["hobby"]?.hasValue == true }, .relation(r))
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
        let q = Query.rename("id", "identifier", .relation(r))
        let s = try! QueryProcessor().execute(query: q)

        print(s.tuples)
    }

    static var allTests = [
        ("testProjection", testProjection),
        ("testSelection",  testSelection),
        ("testRenaming",  testRenaming)
    ]
}
