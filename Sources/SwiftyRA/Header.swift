@dynamicMemberLookup
public struct Header {
    private let names: [AttributeName]
    private let attributesByName: [AttributeName: Attribute]

    public var attributes: [Attribute] {
        return names.map { attributesByName[$0]! }
    }

    init(attributes: [Attribute]) throws {
        try self.init(with: attributes.map { attribute in (attribute.name, attribute.type) })
    }

    init(_ attributes: KeyValuePairs<AttributeName, AttributeType>) throws {
        try self.init(with: Array(attributes))
    }

    private init(with attributes: [(AttributeName, AttributeType)]) throws {
        var names: [AttributeName] = []
        var attributesByName: [AttributeName: Attribute] = [:]

        for (name, type) in attributes {
            guard attributesByName[name] == nil else {
                throw Errors.duplicatedAttribute(name)
            }
            names.append(name)
            attributesByName[name] = Attribute(name: name, type: type)
        }

        self.names = names
        self.attributesByName = attributesByName
    }

    public subscript(name: AttributeName) -> Attribute? {
        attributesByName[name]
    }

    public subscript(dynamicMember member: AttributeName) -> Attribute? {
        attributesByName[member]
    }
}
