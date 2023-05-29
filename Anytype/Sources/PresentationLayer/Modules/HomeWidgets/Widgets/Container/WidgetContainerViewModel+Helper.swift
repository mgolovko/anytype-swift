import Foundation
import BlocksModels

extension WidgetContainerViewModel {
    
    // DI helper
    
    convenience init(
        serviceLocator: ServiceLocator,
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        contentModel: ContentVM,
        output: CommonWidgetModuleOutput?
    ) {
        self.init(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            blockWidgetService: serviceLocator.blockWidgetService(),
            stateManager: stateManager,
            blockWidgetExpandedService: serviceLocator.blockWidgetExpandedService(),
            objectActionsService: serviceLocator.objectActionsService(),
            searchService: serviceLocator.searchService(),
            contentModel: contentModel,
            output: output
        )
    }
}
