import SwiftUI
import Services

protocol SetLayoutSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(setDocument: SetDocumentProtocol) -> AnyView
}

final class SetLayoutSettingsCoordinatorAssembly: SetLayoutSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - SetLayoutSettingsCoordinatorAssemblyProtocol
    
    @MainActor
    func make(setDocument: SetDocumentProtocol) -> AnyView {
        return SetLayoutSettingsCoordinatorView(
            model: SetLayoutSettingsCoordinatorViewModel(
                setDocument: setDocument,
                setLayoutSettingsViewAssembly: self.modulesDI.setLayoutSettingsView(),
                setViewSettingsImagePreviewModuleAssembly: self.modulesDI.setViewSettingsImagePreview(),
                setViewSettingsGroupByModuleAssembly: self.modulesDI.setViewSettingsGroupByView()
            )
        ).eraseToAnyView()
    }
}
