// MARK: Header

/// Serves as a scheme for relation.
/// Stores attributes info in provided order.
/// Emmits only `Header.Error` errors.
/// Provides dynamic member access via property as well as via usual subscript by name.
@dynamicMemberLookup
public struct Header {
    private let names: [AttributeName]
    private let attributesByName: [AttributeName: Attribute]

    public var attributes: [Attribute] {
        return names.map { attributesByName[$0]! }
    }

    public subscript(name: AttributeName) -> Attribute? {
        attributesByName[name]
    }

    public subscript(dynamicMember member: AttributeName) -> Attribute? {
        self[member]
    }
}

// MARK: Creation

public extension Header {
    private init(with attributes: [(AttributeName, AttributeType)]) throws {
        guard attributes.isNotEmpty else {
            throw Errors.empty
        }

        var names: [AttributeName] = []
        var attributesByName: [AttributeName: Attribute] = [:]
        var errors: Set<AttributeName> = []

        for (name, type) in attributes {
            guard attributesByName[name] == nil else {
                errors.insert(name)
                continue
            }
            names.append(name)
            attributesByName[name] = Attribute(name: name, type: type)
        }

        if let errs = errors.decompose().map(OneOrMore.few) {
            throw Errors.duplicates(errs)
        }

        self.names = names
        self.attributesByName = attributesByName
    }

    static func create(attributes: [Attribute]) -> Throws<Header> {
        create(with: attributes.map { attribute in (attribute.name, attribute.type) })
    }

    static func create(_ attributes: KeyValuePairs<AttributeName, AttributeType>) -> Throws<Header> {
        create(with: Array(attributes))
    }

    private static func create(with attributes: [(AttributeName, AttributeType)]) -> Throws<Header> {
        Result
            .init { try Header(with: attributes) }
            .mapError { error in error as! Header.Errors }
    }
}

// MARK: Equality & Hashing

extension Header: Hashable {
    public static func == (lhs: Header, rhs: Header) -> Bool {
        lhs.attributesByName == rhs.attributesByName
    }

    public func hash(into hasher: inout Hasher) {
        attributesByName.hash(into: &hasher)
    }
}
