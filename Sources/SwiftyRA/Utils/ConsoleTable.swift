struct ConsoleTable {
    private typealias Row = [String]
    private typealias Column = (name: String, type: String, maxLength: Int)

    private let columns: [Column]
    private let rows: [Row]

    init(header: Header, tuples: Tuples) {
        var rows: [Row] = []
        var columns: [Column] = header.attributes.map { attribute in
            let name = attribute.name
            let type = attribute.type.debugDescription
            return (name, type, max(name.count, type.count))
        }

        tuples.forEach { tuple in
            var row: Row = []

            columns.enumerated().forEach { index, column in
                let value = tuple[column.name, default: .none]
                let valueDescription = value.debugDescription
                let valueDescriptionLength = valueDescription.count

                row.append(valueDescription)

                if valueDescriptionLength > column.maxLength {
                    columns[index].maxLength = valueDescriptionLength
                }
            }
            rows.append(row)
        }

        self.columns = columns
        self.rows = rows
    }

    func toString() -> String {
        let body = rows
            .map(rowToString)
            .joined(separator: rowSeparator(left: "├", middle: "─", right: "┤", cross: "┼"))

        let top = rowSeparator(left: "┌", middle: "─", right: "┐", cross: "┬")
        let head = [columns.map(\.name), columns.map { _ in "" }, columns.map(\.type)].map(rowToString).joined(separator: "\n")
        let headToBody = rowSeparator(left: "╞", middle: "═", right: "╡", cross: "╪")
        let bottom = rowSeparator(left: "└", middle: "─", right: "┘", cross: "┴")

        return String([top, head, headToBody, body, bottom].joined().dropFirst().dropLast())
    }

    private func rowToString(_ row: Row) -> String {
        let line = zip(columns, row)
            .map { column, value in value + String(repeating: " ", count: column.maxLength - value.count) }
            .joined(separator: " │ ")
        return "│ " + line + " │"
    }

    private func rowSeparator(left: String, middle: String, right: String, cross: String) -> String {
        let body = columns
            .map { String(repeating: middle, count: $0.maxLength) }
            .joined(separator: "\(middle)\(cross)\(middle)")
        return "\n\(left)\(middle)" + body + "\(middle)\(right)\n"
    }
}
