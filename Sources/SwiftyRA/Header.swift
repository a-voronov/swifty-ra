public struct Header {
    private let names: [AttributeName]
    private let attributesByName: [AttributeName: Attribute]

    public var attributes: [Attribute] {
        return names.map { attributesByName[$0]! }
    }

    public init(_ attributes: [(name: AttributeName, type: AttributeType)]) throws {
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

//    init(attributes: [Attribute]) throws {
//        try self.init(attributes.map { attribute in (attribute.name, attribute.type) })
//    }

    public subscript(name: AttributeName) -> Attribute? {
        attributesByName[name]
    }
}

//extension Header {
//    func project(_ attributes: [AttributeName]) throws -> Header {
//        try Header(attributes: try attributes.map { attributeName in
//            guard let attribute = self[attributeName] else {
//                throw Errors.wrongAttribute(attributeName)
//            }
//            return attribute
//        })
//    }
//}
