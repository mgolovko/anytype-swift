import Foundation
import SwiftUI

struct DiscussionTextView: UIViewRepresentable {
    
    private enum Constants {
        static let anytypeFont = AnytypeFont.bodyRegular
        static let font = UIKitFontBuilder.uiKitFont(font: Constants.anytypeFont)
        static let anytypeCodeFont = AnytypeFont.codeBlock
        static let codeFont = UIKitFontBuilder.uiKitFont(font: anytypeCodeFont)
    }
    
    @Binding var text: NSAttributedString
    @Binding var editing: Bool
    @Binding var mention: DiscussionTextMention
    let minHeight: CGFloat
    let maxHeight: CGFloat
    
    @State private var height: CGFloat = 0
    
    func makeCoordinator() -> DiscussionTextViewCoordinator {
        DiscussionTextViewCoordinator(
            text: $text,
            editing: $editing,
            mention: $mention,
            height: $height,
            maxHeight: maxHeight,
            anytypeFont: Constants.anytypeFont,
            anytypeCodeFont: Constants.anytypeCodeFont
        )
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = AnytypeUITextView(usingTextLayoutManager: true)
        textView.delegate = context.coordinator
        textView.textContainerInset = UIEdgeInsets(top: 13, left: 0, bottom: 10, right: 0)
        textView.notEditableAttributes = [.discussionMention]
        textView.backgroundColor = .clear
        
        if let textContentManager = textView.textLayoutManager?.textContentManager {
            textContentManager.delegate = context.coordinator
        }
        
        // Text style
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = Constants.anytypeFont.lineHeightMultiple
        textView.typingAttributes = [
            .font: Constants.font,
            .paragraphStyle: paragraph,
            .kern: Constants.anytypeFont.config.kern
        ]
        textView.textColor = .Text.primary
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        if editing {
            if !textView.isFirstResponder {
                Task { @MainActor in // Async for fix "AttributeGraph: cycle detected through attribute"
                    textView.becomeFirstResponder()
                }
            }
        } else {
            if textView.isFirstResponder {
                Task { @MainActor in // Async for fix "AttributeGraph: cycle detected through attribute"
                    textView.resignFirstResponder()
                }
            }
        }
        
        Task { @MainActor in
            context.coordinator.updateTextIfNeeded(textView: textView, string: text)
        }
    }
   
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        return CGSize(width: proposal.width ?? 0, height: max(minHeight, height))
    }
}

#Preview {
    DiscussionTextView(
        text: .constant(NSAttributedString()),
        editing: .constant(false),
        mention: .constant(.finish),
        minHeight: 54,
        maxHeight: 212
    )
}
