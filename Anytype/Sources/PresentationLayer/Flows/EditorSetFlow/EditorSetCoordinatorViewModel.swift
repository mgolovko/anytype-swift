import Foundation
import Services
import SwiftUI
import AnytypeCore

@MainActor
final class EditorSetCoordinatorViewModel:
    ObservableObject,
    EditorSetModuleOutput,
    SetObjectCreationCoordinatorOutput,
    ObjectSettingsCoordinatorOutput,
    RelationValueCoordinatorOutput
{
    
    private let data: EditorSetObject
    private let editorSetAssembly: EditorSetModuleAssemblyProtocol
    private let setViewPickerCoordinatorAssembly: SetViewPickerCoordinatorAssemblyProtocol
    private let setViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol
    private let setObjectCreationCoordinator: SetObjectCreationCoordinatorProtocol
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private let objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let objectTypeSearchModuleAssembly: ObjectTypeSearchModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let relationValueCoordinator: RelationValueCoordinatorProtocol
    private let setObjectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol
    
    private let toastPresenter: ToastPresenterProtocol
    private let navigationContext: NavigationContextProtocol
    
    var pageNavigation: PageNavigation?
    @Published var dismiss = false
    
    @Published var setViewPickerData: SetViewData?
    @Published var setViewSettingsData: SetViewData?
    @Published var setQueryData: SetQueryData?
    
    init(
        data: EditorSetObject,
        editorSetAssembly: EditorSetModuleAssemblyProtocol,
        setViewPickerCoordinatorAssembly: SetViewPickerCoordinatorAssemblyProtocol,
        setViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol,
        setObjectCreationCoordinator: SetObjectCreationCoordinatorProtocol,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol,
        objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        objectTypeSearchModuleAssembly: ObjectTypeSearchModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        relationValueCoordinator: RelationValueCoordinatorProtocol,
        setObjectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol,
        toastPresenter: ToastPresenterProtocol,
        navigationContext: NavigationContextProtocol
    ) {
        self.data = data
        self.editorSetAssembly = editorSetAssembly
        self.setViewPickerCoordinatorAssembly = setViewPickerCoordinatorAssembly
        self.setViewSettingsCoordinatorAssembly = setViewSettingsCoordinatorAssembly
        self.setObjectCreationCoordinator = setObjectCreationCoordinator
        self.objectSettingCoordinator = objectSettingCoordinator
        self.objectCoverPickerModuleAssembly = objectCoverPickerModuleAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.objectTypeSearchModuleAssembly = objectTypeSearchModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.relationValueCoordinator = relationValueCoordinator
        self.setObjectCreationSettingsCoordinator = setObjectCreationSettingsCoordinator
        self.toastPresenter = toastPresenter
        self.navigationContext = navigationContext
    }
    
    func setModule() -> AnyView {
        editorSetAssembly.make(data: data, output: self)
    }
    
    // MARK: - EditorSetModuleOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pageNavigation?.push(data)
    }
    
    func replaceEditorScreen(data: EditorScreenData) {
        pageNavigation?.replace(data)
    }
    
    func closeEditor() {
        dismiss.toggle()
    }
    
    // MARK: - EditorSetModuleOutput - SetViewPicker
    
    func showSetViewPicker(document: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) {
        setViewPickerData = SetViewData(
            document: document,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
    
    func setViewPicker(data: SetViewData) -> AnyView {
        setViewPickerCoordinatorAssembly.make(
            with: data.document,
            subscriptionDetailsStorage: data.subscriptionDetailsStorage
        )
    }
    
    // MARK: - EditorSetModuleOutput - SetViewSettings
    
    func showSetViewSettings(document: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) {
        setViewSettingsData = SetViewData(
            document: document,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
    
    func setViewSettings(data: SetViewData) -> AnyView {
        setViewSettingsCoordinatorAssembly.make(
            setDocument: data.document,
            viewId: data.document.activeView.id,
            mode: .edit,
            subscriptionDetailsStorage: data.subscriptionDetailsStorage
        )
    }
    
    // MARK: - EditorSetModuleOutput - SetQuery
    func showQueries(document: SetDocumentProtocol, selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ()) {
        setQueryData = SetQueryData(
            document: document,
            selectedObjectId: selectedObjectId,
            onSelect: onSelect
        )
    }
    func setQuery(_ queryData: SetQueryData) -> AnyView {
        if FeatureFlags.newTypePicker {
            return objectTypeSearchModuleAssembly.make(
                title: Loc.Set.SourceType.selectQuery,
                spaceId: data.spaceId,
                showPins: false,
                showLists: false,
                showFiles: true
            ) { [weak self] type in
                queryData.onSelect(type.id)
                self?.setQueryData = nil
            }
        } else {
            return newSearchModuleAssembly.objectTypeSearchModule(
                title: Loc.Set.SourceType.selectQuery,
                spaceId: data.spaceId,
                selectedObjectId: queryData.selectedObjectId,
                excludedObjectTypeId: queryData.document.details?.type,
                showSetAndCollection: false,
                showFiles: true
            ) { [weak self] type in
                queryData.onSelect(type.id)
                self?.setQueryData = nil
            }.eraseToAnyView()
        }
    }
    
    // MARK: - NavigationContext
    
    func showCreateObject(document: SetDocumentProtocol, setting: ObjectCreationSetting?) {
        setObjectCreationCoordinator.startCreateObject(setDocument: document, setting: setting, output: self, customAnalyticsRoute: nil)
    }
    
    func showKanbanColumnSettings(
        hideColumn: Bool,
        selectedColor: BlockBackgroundColor?,
        onSelect: @escaping (Bool, BlockBackgroundColor?) -> Void
    ) {
        let popup = AnytypePopup(
            viewModel: SetKanbanColumnSettingsViewModel(
                hideColumn: hideColumn,
                selectedColor: selectedColor,
                onApplyTap: { [weak self] hidden, backgroundColor in
                    onSelect(hidden, backgroundColor)
                    self?.navigationContext.dismissTopPresented()
                }
            ),
            configuration: .init(
                isGrabberVisible: true,
                dismissOnBackdropView: true
            )
        )
        navigationContext.present(popup)
    }
    
    func showSettings(actionHandler: @escaping (ObjectSettingsAction) -> Void) {
        objectSettingCoordinator.startFlow(
            objectId: data.objectId,
            delegate: self,
            output: self,
            objectSettingsHandler: actionHandler
        )
    }
    
    func showCoverPicker(
        document: BaseDocumentGeneralProtocol,
        onCoverAction: @escaping (ObjectCoverPickerAction) -> Void
    ) {
        let moduleViewController = objectCoverPickerModuleAssembly.make(
            document: document,
            onCoverAction: onCoverAction
        )
        navigationContext.present(moduleViewController)
    }
    
    func showIconPicker(
        document: BaseDocumentGeneralProtocol,
        onIconAction: @escaping (ObjectIconPickerAction) -> Void
    ) {
        let moduleViewController = objectIconPickerModuleAssembly.make(
            document: document,
            onIconAction: onIconAction
        )
        navigationContext.present(moduleViewController)
    }
    
    func showRelationValueEditingView(document: SetDocumentProtocol, key: String) {
        let relation = document.parsedRelations.installed.first { $0.key == key }
        guard let relation = relation else { return }
        guard let objectDetails = document.details else {
            anytypeAssertionFailure("Set document doesn't contains details")
            return
        }
        showRelationValueEditingView(objectDetails: objectDetails, relation: relation)
    }
    
    func showRelationValueEditingView(objectDetails: ObjectDetails, relation: Relation) {
        relationValueCoordinator.startFlow(
            objectDetails: objectDetails,
            relation: relation,
            analyticsType: .dataview,
            output: self
        )
    }
    
    func showSetObjectCreationSettings(
        document: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    ) {
        setObjectCreationSettingsCoordinator.showSetObjectCreationSettings(
            setDocument: document,
            viewId: viewId,
            onTemplateSelection: onTemplateSelection
        )
    }
    
    func showFailureToast(message: String) {
        toastPresenter.showFailureAlert(message: message)
    }
}

extension EditorSetCoordinatorViewModel: ObjectSettingsModuleDelegate {
    func didCreateTemplate(templateId: Services.BlockId) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        guard let objectId = data.objectId else { return }
        UIApplication.shared.hideKeyboard()
        toastPresenter.showObjectName(selfName, middleAction: Loc.Editor.Toast.linkedTo, secondObjectId: objectId) { [weak self] in
            Task { [weak self] in
                self?.showEditorScreen(data: data)
            }
        }
    }
    
    func didTapUseTemplateAsDefault(templateId: BlockId) {
        anytypeAssertionFailure("Invalid delegate method handler")
    }
}

extension EditorSetCoordinatorViewModel {
    struct SetViewData: Identifiable {
        let id = UUID()
        let document: SetDocumentProtocol
        let subscriptionDetailsStorage: ObjectDetailsStorage
    }
    
    struct SetQueryData: Identifiable {
        let id = UUID()
        let document: SetDocumentProtocol
        let selectedObjectId: BlockId?
        let onSelect: (BlockId) -> ()
    }
}
