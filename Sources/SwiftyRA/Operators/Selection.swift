//@dynamicCallable
//public struct Selection {
//    let relation: Relation
//
//    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<AttributeName, Value>) -> Relation {
//        call(with: args.map { key, value in (key, .eq(.value(value))) })
//    }
//
//    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<AttributeName, Operation>) -> Relation {
//        call(with: Array(args))
//    }
//
//    private func call(with args: [(key: AttributeName, value: Operation)]) -> Relation {
//        var attributes = Set(args.map(\.key).filter(\.isNotEmpty))
//        let operations: [AttributeName: Operation] = args.reduce(into: [:]) { acc, pair in
//            guard pair.key.isNotEmpty else {
//                return
//            }
//            if let attr = pair.value.members.attribute {
//                attributes.insert(attr)
//            }
//            acc[pair.key] = pair.value
//        }
//        return relation.select(
//            from: attributes,
//            where: { ctx in
//                try attributes.reduce(into: true) { acc, attribute in
//                    let operation = operations[attribute]!
//                    let res: Bool = try {
//                        switch operation.members {
//                        case let .value(v): return try operation.execute(ctx[attribute, default: .none], v)
//                        case let .attr(a):  return try operation.execute(ctx[attribute, default: .none], ctx[a, default: .none])
//                        }
//                    }()
//                    acc = acc && res
//                }
//            }
//        )
//    }
//}
//
//// TODO: fully support boolean expressions with explicit values operations?
//extension Selection {
//    public enum Operation {
//        public enum Members {
//            case attr(AttributeName)
//            case value(Value)
//
//            var attribute: AttributeName? {
//                guard case let .attr(a) = self else { return nil }
//                return a
//            }
//        }
//
//        case eq(Members)
//        case neq(Members)
//        case gt(Members)
//        case lt(Members)
//        case ge(Members)
//        case le(Members)
//
//        var members: Members {
//            switch self {
//            case let .eq(ms):  return ms
//            case let .neq(ms): return ms
//            case let .gt(ms):  return ms
//            case let .lt(ms):  return ms
//            case let .ge(ms):  return ms
//            case let .le(ms):  return ms
//            }
//        }
//
//        var execute: (Value, Value) throws -> Bool {
//            switch self {
//            case .eq:  return (==)
//            case .neq: return (!=)
//            case .gt:  return (>)
//            case .lt:  return (<)
//            case .ge:  return (>=)
//            case .le:  return (<=)
//            }
//        }
//    }
//}
