import Foundation

final class ObjectTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
    private let widgetsDI: WidgetsDIProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    init(widgetsDI: WidgetsDIProtocol, output: CommonWidgetModuleOutput?) {
        self.widgetsDI = widgetsDI
        self.output = output
    }
    
    // MARK: - HomeWidgetProviderAssemblyProtocol
    
    func make(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        stateManager: HomeWidgetsStateManagerProtocol
    ) -> HomeWidgetProviderProtocol {
        return ObjectTreeWidgetProvider(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            objectTreeWidgetModuleAssembly: widgetsDI.objectTreeWidgetModuleAssembly(),
            stateManager: stateManager,
            output: output
        )
    }
}