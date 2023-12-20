import Services
import Combine
import UIKit
import AnytypeCore

struct EmbedBlockViewModel: BlockViewModelProtocol {

    let info: BlockInformation
    let url: String

    var hashable: AnyHashable {
        [
            info,
            url
        ] as [AnyHashable]
    }

    init(info: BlockInformation, url: String) {
        self.info = info
        self.url = url
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        return EmbedBlockConfiguration(
            content: EmbedBlockContent(url: url)
        )
        .cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration: .init(id: info.id)
        )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
