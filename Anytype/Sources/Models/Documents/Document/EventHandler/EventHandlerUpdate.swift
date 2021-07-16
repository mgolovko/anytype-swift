import BlocksModels

enum EventHandlerUpdate {
    case general
    case update(blockIds: Set<BlockId>)
    case details(DetailsData)
    
    static func merged(lhs: Self, rhs: Self) -> Self {
        switch (lhs, rhs) {
        case (_, .general): return rhs
        case (.general, _): return lhs
        case (_, .details): return rhs
        case (.details, _): return lhs
        case let (.update(left), .update(right)):
            return .update(blockIds: left.union(right))
        }
    }

    var hasUpdate: Bool {
        switch self {
        case .general:
            return true
        case .details:
            return true
        case let .update(update):
            return !update.isEmpty
        }
    }
}
