import BlocksModels

struct BlockLinkState: Hashable, Equatable {
    let title: String
    let description: String
    let style: Style
    let type: ObjectType?
    let viewType: EditorViewType

    // appearance style
    let cardStyle: BlockLink.CardStyle
    let relations: [BlockLink.Relation]
    let iconSize: BlockLink.IconSize
    let descriptionState: BlockLink.Description

    let archived: Bool
    let deleted: Bool
    
    init(details: ObjectDetails,
         cardStyle: BlockLink.CardStyle,
         relations: [BlockLink.Relation],
         iconSize: BlockLink.IconSize,
         descriptionState: BlockLink.Description
    ) {
        var description = ""

        switch descriptionState {
        case .content:
            description = details.snippet
        case .added:
            description = details.description
        case .none:
            description = ""
        }

        self.init(
            title: details.name,
            description: description,
            style: Style(details: details),
            typeId: details.type,
            viewType: details.editorViewType,
            archived: details.isArchived,
            deleted: details.isDeleted,
            cardStyle: cardStyle,
            relations: relations,
            iconSize: iconSize,
            descriptionState: descriptionState
        )
    }
    
    init(title: String,
         description: String,
         style: Style,
         typeId: String,
         viewType: EditorViewType,
         archived: Bool,
         deleted: Bool,
         cardStyle: BlockLink.CardStyle,
         relations: [BlockLink.Relation],
         iconSize: BlockLink.IconSize,
         descriptionState: BlockLink.Description
    ) {
        self.title = title
        self.style = style
        self.type = ObjectTypeProvider.shared.objectType(id: typeId)
        self.viewType = viewType
        self.archived = archived
        self.deleted = deleted
        self.description = description
        self.cardStyle = cardStyle
        self.relations = relations
        self.iconSize = iconSize
        self.descriptionState = descriptionState
    }
    
}

extension BlockLinkState {
    
    static let empty = BlockLinkState(title: .empty, description: .empty, style: .noContent, typeId: "", viewType: .page, archived: false, deleted: false, cardStyle: .text, relations: [], iconSize: .medium, descriptionState: .none)
    
}
