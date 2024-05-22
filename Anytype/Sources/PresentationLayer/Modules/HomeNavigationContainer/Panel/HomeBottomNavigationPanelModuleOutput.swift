import Foundation

@MainActor
protocol HomeBottomNavigationPanelModuleOutput: AnyObject {
    func onSearchSelected()
    func onCreateObjectSelected(screenData: EditorScreenData)
    func onProfileSelected()
    func onHomeSelected()
    func onSheetDismiss()
    func onSheetPresent()
    func onForwardSelected()
    func onBackwardSelected()
    func onPickTypeForNewObjectSelected()
}
