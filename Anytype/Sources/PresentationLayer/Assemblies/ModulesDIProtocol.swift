import Foundation

protocol ModulesDIProtocol: AnyObject {
    func relationValue() -> RelationValueModuleAssemblyProtocol
    func relationsList() -> RelationsListModuleAssemblyProtocol
    func textRelationEditing() -> TextRelationEditingModuleAssemblyProtocol
    func undoRedo() -> UndoRedoModuleAssemblyProtocol
    func objectLayoutPicker() -> ObjectLayoutPickerModuleAssemblyProtocol
    func objectIconPicker() -> ObjectIconPickerModuleAssemblyProtocol
    func objectSetting() -> ObjectSettingModuleAssemblyProtocol
    func createObject() -> CreateObjectModuleAssemblyProtocol
    func newSearch() -> NewSearchModuleAssemblyProtocol
    func newRelation() -> NewRelationModuleAssemblyProtocol
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol
    func textIconPicker() -> TextIconPickerModuleAssemblyProtocol
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol
    func settingsAppearance() -> SettingsAppearanceModuleAssemblyProtocol
    func dashboardAlerts() -> DashboardAlertsAssemblyProtocol
    func authorization() -> AuthModuleAssemblyProtocol
    func joinFlow() -> JoinFlowModuleAssemblyProtocol
    func login() -> LoginViewModuleAssemblyProtocol
    func authKey() -> KeyPhraseViewModuleAssemblyProtocol
    func authKeyMoreInfo() -> KeyPhraseMoreInfoViewModuleAssembly
    func authSoul() -> SoulViewModuleAssemblyProtocol
    func authCreatingSoul() -> CreatingSoulViewModuleAssemblyProtocol
    func setObjectCreationSettings() -> SetObjectCreationSettingsModuleAssemblyProtocol
    func setViewSettingsList() -> SetViewSettingsListModuleAssemblyProtocol
    func setFiltersListModule() -> SetFiltersListModuleAssemblyProtocol
    func setViewSettingsImagePreview() -> SetViewSettingsImagePreviewModuleAssemblyProtocol
    func setLayoutSettingsView() -> SetLayoutSettingsViewAssemblyProtocol
    func setViewSettingsGroupByView() -> SetViewSettingsGroupByModuleAssemblyProtocol
    func setRelationsView() -> SetRelationsViewModuleAssemblyProtocol
    func setViewPicker() -> SetViewPickerModuleAssemblyProtocol
    func homeBottomNavigationPanel() -> HomeBottomNavigationPanelModuleAssemblyProtocol
    func deleteAccount() -> DeleteAccountModuleAssemblyProtocol
    func objectTypeSearch() -> ObjectTypeSearchModuleAssemblyProtocol
    func serverConfiguration() -> ServerConfigurationModuleAssemblyProtocol
    func serverDocumentPicker() -> ServerDocumentPickerModuleAssemblyProtocol
}
