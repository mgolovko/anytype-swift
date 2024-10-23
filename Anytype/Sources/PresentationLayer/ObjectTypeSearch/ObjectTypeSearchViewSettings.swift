struct ObjectTypeSearchViewSettings {
    let showPins: Bool
    let showLists: Bool
    let showFiles: Bool
    let showChat: Bool
    let showTemplates: Bool
    let incudeNotForCreation: Bool
    let allowPaste: Bool
}

extension ObjectTypeSearchViewSettings {
    static let newObjectCreation = ObjectTypeSearchViewSettings(
        showPins: true,
        showLists: true,
        showFiles: false,
        showChat: true,
        showTemplates: false,
        incudeNotForCreation: false,
        allowPaste: true
    )
    
    static let queryInSet = ObjectTypeSearchViewSettings(
        showPins: false,
        showLists: false,
        showFiles: true,
        showChat: false,
        showTemplates: true,
        incudeNotForCreation: true,
        allowPaste: false
    )
    
    static let setByRelationNewObject = ObjectTypeSearchViewSettings(
        showPins: false,
        showLists: true,
        showFiles: false,
        showChat: false,
        showTemplates: false,
        incudeNotForCreation: false,
        allowPaste: false
    )
    
    static let editorChangeType = ObjectTypeSearchViewSettings(
        showPins: false,
        showLists: false,
        showFiles: false,
        showChat: false,
        showTemplates: false,
        incudeNotForCreation: false,
        allowPaste: false
    )
    
    static let spaceDefaultObject = ObjectTypeSearchViewSettings(
        showPins: false,
        showLists: false,
        showFiles: false,
        showChat: false,
        showTemplates: false,
        incudeNotForCreation: false,
        allowPaste: false
    )
}
