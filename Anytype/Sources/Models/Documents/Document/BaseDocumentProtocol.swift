import BlocksModels
import Combine

protocol BaseDocumentProtocol: AnyObject {
    var objectId: BlockId { get }
    
    var blocksContainer: BlockContainerModelProtocol { get }
    var detailsStorage: ObjectDetailsStorageProtocol { get }
    

    var onUpdateReceive: ((EventsListenerUpdate) -> Void)? { get set }
    
    func open()
    
    var objectDetails: ObjectDetails? { get }
    var flattenBlocks: [BlockModelProtocol] { get }

    func pageDetailsPublisher() -> AnyPublisher<DetailsDataProtocol?, Never>
    
}
