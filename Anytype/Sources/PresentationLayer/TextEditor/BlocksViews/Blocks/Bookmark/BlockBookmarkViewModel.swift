import Combine
import BlocksModels
import UIKit

struct BlockBookmarkViewModel: BlockViewModelProtocol {    
    var diffable: AnyHashable {
        [
            blockId,
            bookmarkData,
            indentationLevel
        ] as [AnyHashable]
    }
    
    let indentationLevel: Int
    
    let information: BlockInformation
    let bookmarkData: BlockBookmark
    
    let contextualMenuHandler: DefaultContextualMenuHandler
    
    let showBookmarkBar: (BlockInformation) -> ()
    let openUrl: (URL) -> ()
    
    func makeContentConfiguration() -> UIContentConfiguration {
        BlockBookmarkConfiguration(bookmarkData: bookmarkData)
    }
    
    func didSelectRowInTableView() {
        guard let url = URL(string: bookmarkData.url) else {
            showBookmarkBar(information)
            return
        }
        
        openUrl(url)
    }

    func makeContextualMenu() -> [ContextualMenu] {
        [ .addBlockBelow, .duplicate, .delete ]
    }
    
    func handle(action: ContextualMenu) {
        contextualMenuHandler.handle(action: action, info: information)
    }
}
