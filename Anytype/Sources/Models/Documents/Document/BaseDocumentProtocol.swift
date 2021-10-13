import BlocksModels
import Combine

struct BaseDocumentUpdateResult {
    let updates: EventHandlerUpdate
    let details: ObjectDetails?
    let models: [BlockModelProtocol]
}

protocol BaseDocumentProtocol: AnyObject {
    var objectId: BlockId { get }
    var rootActiveModel: BlockModelProtocol? { get }
    
    var blocksContainer: BlockContainerModelProtocol { get }
    var detailsStorage: ObjectDetailsStorageProtocol { get }
    
    var eventHandler: EventsListener { get }
    
    var onUpdateReceive: ((BaseDocumentUpdateResult) -> Void)? { get set }
    
    func open()
    
    func pageDetailsPublisher() -> AnyPublisher<DetailsDataProtocol?, Never>
    
}
