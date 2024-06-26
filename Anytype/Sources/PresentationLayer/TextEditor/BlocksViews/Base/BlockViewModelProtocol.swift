import UIKit
import Services
import AnytypeCore

@MainActor
protocol BlockViewModelProtocol:
    ContentConfigurationProvider,
    BlockInformationProvider
{ }

protocol HashableProvier {
    var hashable: AnyHashable { get }
}

protocol ContentConfigurationProvider: HashableProvier, BlockFocusing {
    func makeContentConfiguration(maxWidth: CGFloat) -> any UIContentConfiguration

    func makeSpreadsheetConfiguration() -> any UIContentConfiguration
}

extension ContentConfigurationProvider {
    func makeSpreadsheetConfiguration() -> any UIContentConfiguration {
        anytypeAssertionFailure(
            "This content configuration doesn't support spreadsheet"
        )
        return EmptyRowConfiguration(id: "", action: {} )
            .spreadsheetConfiguration(
                dragConfiguration: nil,
                styleConfiguration: CellStyleConfiguration(backgroundColor: .Background.primary)
            )
    }
}

protocol BlockFocusing {
    func didSelectRowInTableView(editorEditingState: EditorEditingState)

    func set(focus: BlockFocusPosition)
}

extension BlockFocusing {
    func set(focus: BlockFocusPosition) { }
}

protocol BlockInformationProvider {
    var info: BlockInformation { get }
}

// MARK: - Extensions

extension BlockInformationProvider {
    var blockId: String { info.id }
    var content: BlockContent { info.content }
}
