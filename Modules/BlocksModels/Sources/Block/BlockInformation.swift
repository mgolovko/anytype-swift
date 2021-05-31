import ProtobufMessages


public enum BlockInformation {
    public typealias BackgroundColor = String
    
    public struct InformationModel {
        public typealias ChildrenIds = [BlockId]

        public var id: BlockId
        public var childrenIds: ChildrenIds = []
        public var content: BlockContent
        
        public var fields: [String: BlockFieldType] = [:]
        var restrictions: [String] = []
        
        public var backgroundColor: BackgroundColor = ""
        public var alignment: Alignment = .left
                
        static func defaultValue() -> Self { .default }
        
        public init(id: BlockId, content: BlockContent) {
            self.id = id
            self.content = content
        }
        
        public init(information: Self) {
            self.id = information.id
            self.content = information.content
            self.childrenIds = information.childrenIds
            
            self.fields = information.fields
            self.restrictions = information.restrictions
            
            self.backgroundColor = information.backgroundColor
            self.alignment = information.alignment
        }
        
        private static let `defaultId`: BlockId = "DefaultIdentifier"
        private static let `defaultBlockType`: BlockContent = .text(.createDefault(text: "DefaultText"))
        private static let `default`: Self = .init(id: Self.defaultId, content: Self.defaultBlockType)
    }
}

// MARK: Hashable
extension BlockInformation.InformationModel: Hashable {

}

extension BlockInformation.Alignment: Hashable {}

// MARK: Alignment
extension BlockInformation {
    public enum Alignment: CaseIterable {
        case left, center, right
    }
}

// MARK: Details as Information
extension BlockInformation {
    /// What happens here?
    /// We convert details ( PageDetails ) to ready-to-use information.
    struct DetailsAsInformationConverter {
        
        var blockId: BlockId

        private func detailsAsInformation(_ blockId: BlockId, _ details: DetailsEntry<AnyHashable>) -> InformationModel {
            /// Our ID is <ID>/<Details.key>.
            /// Look at implementation in `IdentifierBuilder`
            
            let id = BlockInformation.DetailsAsBlockConverter.IdentifierBuilder.asBlockId(blockId, details.id)

            /// Actually, we don't care about block type.
            /// We only take care about "distinct" block model.
            let content: BlockContent = .text(.empty())
            return InformationModel(id: id, content: content)
        }

        func callAsFunction(_ details: DetailsEntry<AnyHashable>) -> InformationModel {
            detailsAsInformation(self.blockId, details)
        }
    }
}

/// TODO: Time to remove Details Crutches. ?????????????
public extension BlockInformation.DetailsAsBlockConverter {
    struct IdentifierBuilder {
        
        static var separator: Character = "/"
        public static func asBlockId(_ blockId: BlockId, _ id: ParentId) -> BlockId {
            blockId + "\(self.separator)" + id
        }
        public static func asDetails(_ id: BlockId) -> (BlockId, ParentId) {
            guard let index = id.lastIndex(of: self.separator) else { return (id, "") }
            let substring = id[index...].dropFirst()
            let prefix = String(id.prefix(upTo: index))
            switch DetailsKind(rawValue: String(substring)) {
            case .name: return (prefix, DetailsKind.name.rawValue)
            case .iconEmoji: return (prefix, DetailsKind.iconEmoji.rawValue)
            default: return ("", "")
            }
        }
    }
}

// MARK: Details as Block
public extension BlockInformation {
    /// We need this converter to convert our details into a block.
    /// First, we convert them to an Information structure.
    /// Then, we convert it to block.
    ///
    /// Why do we need it?
    /// We need it to get block and later configure blocks views with this block and then render them.
    ///
    struct DetailsAsBlockConverter {
        
        // MARK: - Private variables
        
        private let blockId: BlockId

        // MARK: - Initializer
        
        public init(blockId: BlockId) {
            self.blockId = blockId
        }
        
        // MARK: - Public functions
        
        public func convertDetailsToBlock(_ details: DetailsEntry<AnyHashable>) -> BlockModelProtocol {
            TopLevelBuilder.blockBuilder.createBlockModel(
                with: DetailsAsInformationConverter(blockId: self.blockId)(details)
            )
        }
        
    }
}
