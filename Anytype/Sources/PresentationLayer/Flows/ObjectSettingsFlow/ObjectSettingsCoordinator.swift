import Foundation
import Services
import AnytypeCore

@MainActor
protocol ObjectSettingsCoordinatorProtocol {
    func startFlow(
        objectId: String,
        delegate: ObjectSettingsModuleDelegate,
        output: ObjectSettingsCoordinatorOutput?,
        objectSettingsHandler: @escaping (ObjectSettingsAction) -> Void
    )
}

@MainActor
final class ObjectSettingsCoordinator: ObjectSettingsCoordinatorProtocol,
                                       ObjectSettingsModelOutput,
                                       RelationValueCoordinatorOutput {
    private let navigationContext: NavigationContextProtocol
    private let objectSettingsModuleAssembly: ObjectSettingModuleAssemblyProtocol
    private let objectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let relationsListCoordinatorAssembly: RelationsListCoordinatorAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let documentsProvider: DocumentsProviderProtocol
    
    private weak var output: ObjectSettingsCoordinatorOutput?
    
    init(
        navigationContext: NavigationContextProtocol,
        objectSettingsModuleAssembly: ObjectSettingModuleAssemblyProtocol,
        objectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        relationsListCoordinatorAssembly: RelationsListCoordinatorAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        documentsProvider: DocumentsProviderProtocol
    ) {
        self.navigationContext = navigationContext
        self.objectSettingsModuleAssembly = objectSettingsModuleAssembly
        self.objectLayoutPickerModuleAssembly = objectLayoutPickerModuleAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.relationsListCoordinatorAssembly = relationsListCoordinatorAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.documentsProvider = documentsProvider
    }
    
    func startFlow(
        objectId: String,
        delegate: ObjectSettingsModuleDelegate,
        output: ObjectSettingsCoordinatorOutput?,
        objectSettingsHandler: @escaping (ObjectSettingsAction) -> Void
    ) {
        self.output = output
        let document = documentsProvider.document(objectId: objectId, forPreview: false)
        Task { @MainActor in
            do {
                try await document.open()
                let moduleViewController = objectSettingsModuleAssembly.make(
                    document: document,
                    output: self,
                    delegate: delegate,
                    actionHandler: objectSettingsHandler
                )
                
                navigationContext.present(moduleViewController)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    // MARK: - ObjectSettingsModelOutput
    
    func undoRedoAction(document: BaseDocumentProtocol) {
        // TODO: Move to editor
        navigationContext.dismissTopPresented(animated: false)
        navigationContext.present(UndoRedoViewController(objectId: document.objectId))
    }
    
    func layoutPickerAction(document: BaseDocumentProtocol) {
        let moduleViewController = objectLayoutPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
    
    func showCoverPicker(document: BaseDocumentGeneralProtocol, onCoverAction: @escaping (ObjectCoverPickerAction) -> Void) {
        let data = ObjectCoverPickerData(document: document, onCoverAction: onCoverAction)
        navigationContext.present(ObjectCoverPicker(data: data))
    }
    
    func showIconPicker(
        document: BaseDocumentGeneralProtocol,
        onIconAction: @escaping (ObjectIconPickerAction) -> Void
    ) {
        let moduleViewController = objectIconPickerModuleAssembly.make(document: document, onIconAction: onIconAction)
        navigationContext.present(moduleViewController)
    }
    
    func relationsAction(document: BaseDocumentProtocol) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.objectRelationShow)
        
        let view = relationsListCoordinatorAssembly.make(document: document, output: self)
        navigationContext.present(view)
    }
    
    func openPageAction(screenData: EditorScreenData) {
        output?.showEditorScreen(data: screenData)
    }
    
    func linkToAction(document: BaseDocumentProtocol, onSelect: @escaping (String) -> ()) {
        let excludedLayouts = DetailsLayout.fileLayouts + [.set, .participant]
        let moduleView = newSearchModuleAssembly.blockObjectsSearchModule(
            title: Loc.linkTo,
            spaceId: document.spaceId,
            excludedObjectIds: [document.objectId],
            excludedLayouts: excludedLayouts
        ) { [weak navigationContext] details in
            navigationContext?.dismissAllPresented(animated: true) {
                onSelect(details.id)
            }
        }

        navigationContext.presentSwiftUIView(view: moduleView)
    }
    
    func closeEditorAction() {
        output?.closeEditor()
    }
    
    // MARK: - RelationValueCoordinatorOutput
    
    func showEditorScreen(data: EditorScreenData) {
        navigationContext.dismissAllPresented(animated: true) { [weak self] in
            self?.output?.showEditorScreen(data: data)
        }
    }
}
