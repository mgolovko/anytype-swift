import AnytypeCore
import UIKit

extension TextBlockContentView: CustomTextViewDelegate {    
    func changeFirstResponderState(_ change: CustomTextViewFirstResponderChange) {
        switch change {
        case .become:
            blockDelegate.becomeFirstResponder(blockId: currentConfiguration.information.id)
        case .resign:
            blockDelegate.resignFirstResponder(blockId: currentConfiguration.information.id)
        }
    }
    
    func willBeginEditing() {
        accessoryDelegate.willBeginEditing(data: accessoryViewData)
        blockDelegate.willBeginEditing()
    }

    func didBeginEditing() {
        blockDelegate.didBeginEditing()
    }
    
    func didEndEditing() {
        accessoryDelegate.didEndEditing()
    }

    func didReceiveAction(_ action: CustomTextView.UserAction) -> Bool {
        switch action {
        case .changeText:
            handler.handleAction(
                .textView(action: action, info: currentConfiguration.information),
                blockId: currentConfiguration.information.id
            )

            accessoryDelegate.textDidChange()
        case let .keyboardAction(keyAction):
            switch keyAction {
            case .enterInsideContent,
                 .enterAtTheEndOfContent,
                 .enterAtTheBeginingOfContent:
                // In the case of frequent pressing of enter
                // we can send multiple split requests to middle
                // from the same block, it will leads to wrong order of blocks in array,
                // adding a delay makes impossible to press enter very often
                if currentConfiguration.pressingEnterTimeChecker.exceedsTimeInterval() {
                    handler.handleAction(
                        .textView(action: action, info: currentConfiguration.information),
                        blockId: currentConfiguration.information.id
                    )
                }
                return false
            default:
                break
            }
            handler.handleAction(
                .textView(action: action, info: currentConfiguration.information),
                blockId: currentConfiguration.information.id
            )
        case .changeTextStyle, .changeCaretPosition:
            handler.handleAction(
                .textView(action: action, info: currentConfiguration.information),
                blockId: currentConfiguration.information.id
            )
        case let .shouldChangeText(range, replacementText, mentionsHolder):
            accessoryDelegate.textWillChange(
                replacementText: replacementText,
                range: range
            )
            let shouldChangeText = !mentionsHolder.removeMentionIfNeeded(text: replacementText)
            if !shouldChangeText {
                handler.handleAction(
                    .textView(
                        action: .changeText(textView.textView.attributedText),
                        info: currentConfiguration.information
                    ),
                    blockId: currentConfiguration.information.id
                )
            }
            return shouldChangeText
        case let .changeLink(attrText, range):
            handler.showLinkToSearch(
                blockId: currentConfiguration.information.id,
                attrText: attrText,
                range: range
            )
        case let .showPage(pageId):
            guard let details = currentConfiguration.detailsStorage.get(id: pageId) else {
                // Deleted objects goes here
                return false
            }
            
            if !details.isArchived && !details.isDeleted {
                currentConfiguration.showPage(pageId)
            }
        case let .openURL(url):
            currentConfiguration.openURL(url)
        }
        return true
    }
    
    // MARK: - Private
    private var blockDelegate: BlockDelegate {
        currentConfiguration.blockDelegate
    }
    
    private var accessoryDelegate: AccessoryTextViewDelegate {
        currentConfiguration.accessoryDelegate
    }
    
    private var handler: EditorActionHandlerProtocol {
        currentConfiguration.actionHandler
    }
    
    private var accessoryViewData: AccessoryViewSwitcherData {
        AccessoryViewSwitcherData(
            textView: textView,
            info: currentConfiguration.information,
            text: currentConfiguration.content.anytypeText(using: currentConfiguration.detailsStorage)
        )
    }
}
