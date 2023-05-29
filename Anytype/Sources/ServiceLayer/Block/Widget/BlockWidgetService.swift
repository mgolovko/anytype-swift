import Foundation
import ProtobufMessages
import BlocksModels
import AnytypeCore

protocol BlockWidgetServiceProtocol {
    func createWidgetBlock(contextId: String, sourceId: String, layout: BlockWidget.Layout, position: WidgetPosition) async throws
    func removeWidgetBlock(contextId: String, widgetBlockId: String) async throws
    func replaceWidgetBlock(contextId: String, widgetBlockId: String, sourceId: String, layout: BlockWidget.Layout) async throws
}

final class BlockWidgetService: BlockWidgetServiceProtocol {
    
    private let blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    
    init(blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol) {
        self.blockWidgetExpandedService = blockWidgetExpandedService
    }
    
    // MARK: - BlockWidgetServiceProtocol
    
    func createWidgetBlock(contextId: String, sourceId: String, layout: BlockWidget.Layout, position: WidgetPosition) async throws {
        
        let info = BlockInformation.empty(content: .link(.empty(targetBlockID: sourceId)))
        guard let block = BlockInformationConverter.convert(information: info) else {
            throw anytypeAssertionFailureWithError("Block not created", domain: .blockWidgetService)
        }
        
        try await ClientCommands.blockCreateWidget(.with {
            $0.contextID = contextId
            $0.targetID = position.targetId
            $0.block = block
            $0.position = position.middlePosition
            $0.widgetLayout = layout.asMiddleware
        }).invoke(errorDomain: .blockWidgetService)
    }
    
    func removeWidgetBlock(contextId: String, widgetBlockId: String) async throws {
        try await ClientCommands.blockListDelete(.with {
            $0.contextID = contextId
            $0.blockIds = [widgetBlockId]
        }).invoke(errorDomain: .blockWidgetService)
    }
    
    func replaceWidgetBlock(contextId: String, widgetBlockId: String, sourceId: String, layout: BlockWidget.Layout) async throws {
        
        let info = BlockInformation.empty(content: .link(.empty(targetBlockID: sourceId)))
        guard let block = BlockInformationConverter.convert(information: info) else {
            throw anytypeAssertionFailureWithError("Block not created", domain: .blockWidgetService)
        }
        
        let result = try await ClientCommands.blockCreateWidget(.with {
            $0.contextID = contextId
            $0.targetID = widgetBlockId
            $0.block = block
            $0.position = .replace
            $0.widgetLayout = layout.asMiddleware
        }).invoke(errorDomain: .blockWidgetService)
        
        let expandedState = blockWidgetExpandedService.isExpanded(widgetBlockId: widgetBlockId)
        blockWidgetExpandedService.setState(widgetBlockId: result.blockID, isExpanded: expandedState)
        blockWidgetExpandedService.deleteState(widgetBlockId: widgetBlockId)
    }
}
