import Foundation
import SwiftUI

protocol ApplicationCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func makeView() -> AnyView
}

final class ApplicationCoordinatorAssembly: ApplicationCoordinatorAssemblyProtocol {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let modulesDI: ModulesDIProtocol

    init(
        coordinatorsDI: CoordinatorsDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        modulesDI: ModulesDIProtocol
    ) {
        self.coordinatorsDI = coordinatorsDI
        self.uiHelpersDI = uiHelpersDI
        self.modulesDI = modulesDI
    }
    
    // MARK: - ApplicationCoordinatorAssemblyProtocol
    
    @MainActor
    func makeView() -> AnyView {
        return ApplicationCoordinatorView(
            model: ApplicationCoordinatorViewModel(
                authCoordinatorAssembly: self.coordinatorsDI.authorization(),
                homeCoordinatorAssembly: self.coordinatorsDI.home(),
                deleteAccountModuleAssembly: self.modulesDI.deleteAccount(),
                initialCoordinatorAssembly: self.coordinatorsDI.initial(), 
                navigationContext: self.uiHelpersDI.commonNavigationContext()
            )
        ).eraseToAnyView()
    }
}
