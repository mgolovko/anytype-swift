import Foundation
import Services

@MainActor
protocol EditorPageModuleOutput: AnyObject, ObjectHeaderModuleOutput {
    func showEditorScreen(data: EditorScreenData)
    func replaceEditorScreen(data: EditorScreenData)
    func closeEditor()
    func onSelectCodeLanguage(objectId: String, blockId: String)
    func showRelationValueEditingView(document: some BaseDocumentProtocol, relation: Relation)
    func showLinkToObject(data: LinkToObjectSearchModuleData)
    func showIconPicker(document: some BaseDocumentProtocol)
    func showTextIconPicker(data: TextIconPickerData)
    func showBlockObjectSearch(data: BlockObjectSearchData)
    func didUndoRedo()
    func versionRestored(_ text: String)
    func openUrl(_ url: URL)
    func showSyncStatusInfo(spaceId: String)
    func showAddNewRelationView(document: some BaseDocumentProtocol, onSelect: @escaping (RelationDetails, _ isNew: Bool) -> Void)
    // TODO: Refactoring templates. Delete it
    func setModuleInput(input: some EditorPageModuleInput, objectId: String)
    // TODO: Open toast inside module
    func showFailureToast(message: String)
    // TODO: Migrate EditorRouter to EditorPageCoordinator and make output as MainActor
}
