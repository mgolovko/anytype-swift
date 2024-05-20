import Foundation
import SwiftUI

final class FavoriteCompactListWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - HomeWidgetCommonAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        
        let model = FavoriteWidgetInternalViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            output: output
        )
     
        return ListWidgetView(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            style: .compactList,
            stateManager: stateManager,
            internalModel: model,
            internalHeaderModel: nil,
            output: output
        ).eraseToAnyView()
    }
}
