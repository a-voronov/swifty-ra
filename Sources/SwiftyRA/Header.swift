/// Serves as a scheme for relation.
/// Stores attributes info in provided order.
/// Emmits only `Header.Error` errors.
/// Provides dynamic member access via property as well as via usual subscript by name.
@dynamicMemberLookup
public struct Header {
    public enum Errors: Error, Hashable {
        case empty
        case duplicates(Set<AttributeName>)
    }

    private let names: [AttributeName]
    private let attributesByName: [AttributeName: Attribute]

    public var attributes: [Attribute] {
        return names.map { attributesByName[$0]! }
    }

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

        guard errors.isEmpty else {
            throw Errors.duplicates(errors)
        }

        self.names = names
        self.attributesByName = attributesByName
    }

    public subscript(name: AttributeName) -> Attribute? {
        attributesByName[name]
    }

    public subscript(dynamicMember member: AttributeName) -> Attribute? {
        self[member]
    }
}

extension Header: Hashable {
    public static func == (lhs: Header, rhs: Header) -> Bool {
        lhs.attributesByName == rhs.attributesByName
    }

    public func hash(into hasher: inout Hasher) {
        attributesByName.hash(into: &hasher)
    }
}

public extension Header {
    static func create(attributes: [Attribute]) -> Result<Header, Header.Errors> {
        create(with: attributes.map { attribute in (attribute.name, attribute.type) })
    }

    static func create(_ attributes: KeyValuePairs<AttributeName, AttributeType>) -> Result<Header, Header.Errors> {
        create(with: Array(attributes))
    }

    private static func create(with attributes: [(AttributeName, AttributeType)]) -> Result<Header, Header.Errors> {
        Result
            .init { try Header(with: attributes) }
            .mapError { error in error as! Header.Errors }
    }
}
