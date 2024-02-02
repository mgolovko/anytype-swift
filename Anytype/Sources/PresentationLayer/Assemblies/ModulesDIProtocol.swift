import Foundation

protocol ModulesDIProtocol: AnyObject {
    func relationValue() -> RelationValueModuleAssemblyProtocol
    func relationsList() -> RelationsListModuleAssemblyProtocol
    func dateRelationCalendar() -> DateRelationCalendarModuleAssemblyProtocol
    func selectRelationList() -> SelectRelationListModuleAssemblyProtocol
    func relationOptionSettings() -> RelationOptionSettingsModuleAssemblyProtocol
    func undoRedo() -> UndoRedoModuleAssemblyProtocol
    func objectLayoutPicker() -> ObjectLayoutPickerModuleAssemblyProtocol
    func objectCoverPicker() -> ObjectCoverPickerModuleAssemblyProtocol
    func objectIconPicker() -> ObjectIconPickerModuleAssemblyProtocol
    func objectSetting() -> ObjectSettingModuleAssemblyProtocol
    func search() -> SearchModuleAssemblyProtocol
    func createObject() -> CreateObjectModuleAssemblyProtocol
    func codeLanguageList() -> CodeLanguageListModuleAssemblyProtocol
    func newSearch() -> NewSearchModuleAssemblyProtocol
    func newRelation() -> NewRelationModuleAssemblyProtocol
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol
    func textIconPicker() -> TextIconPickerModuleAssemblyProtocol
    func widgetType() -> WidgetTypeModuleAssemblyProtocol
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol
    func settingsAppearance() -> SettingsAppearanceModuleAssemblyProtocol
    func wallpaperPicker() -> WallpaperPickerModuleAssemblyProtocol
    func about() -> AboutModuleAssemblyProtocol
    func personalization() -> PersonalizationModuleAssemblyProtocol
    func keychainPhrase() -> KeychainPhraseModuleAssemblyProtocol
    func dashboardAlerts() -> DashboardAlertsAssemblyProtocol
    func settings() -> SettingsModuleAssemblyProtocol
    func debugMenu() -> DebugMenuModuleAssemblyProtocol
    func settingsAccount() -> SettingsAccountModuleAssemblyProtocol
    func fileStorage() -> FileStorageModuleAssemblyProtocol
    func spaceSwitch() -> SpaceSwitchModuleAssemblyProtocol
    func spaceCreate() -> SpaceCreateModuleAssemblyProtocol
    func authorization() -> AuthModuleAssemblyProtocol
    func joinFlow() -> JoinFlowModuleAssemblyProtocol
    func login() -> LoginViewModuleAssemblyProtocol
    func authKey() -> KeyPhraseViewModuleAssemblyProtocol
    func authKeyMoreInfo() -> KeyPhraseMoreInfoViewModuleAssembly
    func authSoul() -> SoulViewModuleAssemblyProtocol
    func authCreatingSoul() -> CreatingSoulViewModuleAssemblyProtocol
    func spaceSettings() -> SpaceSettingsModuleAssemblyProtocol
    func remoteStorage() -> RemoteStorageModuleAssemblyProtocol
    func setObjectCreationSettings() -> SetObjectCreationSettingsModuleAssemblyProtocol
    func setViewSettingsList() -> SetViewSettingsListModuleAssemblyProtocol
    func setSortsList() -> SetSortsListModuleAssemblyProtocol
    func setSortTypesList() -> SetSortTypesListModuleAssemblyProtocol
    func setTextView() -> SetTextViewModuleAssemblyProtocol
    func setFiltersDateView() -> SetFiltersDateViewModuleAssemblyProtocol
    func setFilterConditions() -> SetFilterConditionsModuleAssemblyProtocol
    func setFiltersSelectionHeader() -> SetFiltersSelectionHeaderModuleAssemblyProtocol
    func setFiltersSelectionView() -> SetFiltersSelectionViewModuleAssemblyProtocol
    func setFiltersTextView() -> SetFiltersTextViewModuleAssemblyProtocol
    func setFiltersCheckboxView() -> SetFiltersCheckboxViewModuleAssemblyProtocol
    func setFiltersListModule() -> SetFiltersListModuleAssemblyProtocol
    func setViewSettingsImagePreview() -> SetViewSettingsImagePreviewModuleAssemblyProtocol
    func setLayoutSettingsView() -> SetLayoutSettingsViewAssemblyProtocol
    func setViewSettingsGroupByView() -> SetViewSettingsGroupByModuleAssemblyProtocol
    func setRelationsView() -> SetRelationsViewModuleAssemblyProtocol
    func shareAssembly() -> ShareModuleAssemblyProtocol
    func setViewPicker() -> SetViewPickerModuleAssemblyProtocol
    func homeBottomNavigationPanel() -> HomeBottomNavigationPanelModuleAssemblyProtocol
    func deleteAccount() -> DeleteAccountModuleAssemblyProtocol
    func objectTypeSearch() -> ObjectTypeSearchModuleAssemblyProtocol
    func serverConfiguration() -> ServerConfigurationModuleAssemblyProtocol
    func serverDocumentPicker() -> ServerDocumentPickerModuleAssemblyProtocol
    func sharingTip() -> SharingTipModuleAssemblyProtocol
}
