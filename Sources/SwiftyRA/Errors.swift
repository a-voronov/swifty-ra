public enum Errors: Error {
//    enum Header: Error {
//        enum Creation: Error {
//
//        }
//    }
    case emptyHeader
    case duplicatedAttribute(AttributeName)
    case wrongAttribute(AttributeName)
    case wrongAttributes(Set<AttributeName>)
    case incompatibleValues(Value, Value)
}
