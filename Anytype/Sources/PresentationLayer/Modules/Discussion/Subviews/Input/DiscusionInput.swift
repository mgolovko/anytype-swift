import SwiftUI

struct DiscusionInput: View {
    
    @Binding var text: NSAttributedString
    @Binding var editing: Bool
    @Binding var mention: DiscussionTextMention
    let hasAdditionalData: Bool
    let onTapAddObject: () -> Void
    let onTapSend: () -> Void
    
    @Environment(\.discussionColorTheme) private var colors
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.setHomeBottomPanelHidden) @Binding private var setBottomPanelHidden
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            
            if setBottomPanelHidden {
                Button {
                    keyboardDismiss()
                    pageNavigation.pop()
                } label: {
                    Image(asset: .X32.Arrow.left)
                        .foregroundColor(colors.inputAction)
                }
                .frame(height: 56)
                
            }
            
            ZStack(alignment: .topLeading) {
                DiscussionTextView(text: $text, editing: $editing, mention: $mention, minHeight: 56, maxHeight: 212)
                if text.string.isEmpty {
                    Text(Loc.Message.Input.emptyPlaceholder)
                        .anytypeStyle(.bodyRegular)
                        .foregroundColor(.Text.tertiary)
                        .padding(.leading, 6)
                        .padding(.top, 15)
                        .allowsHitTesting(false)
                        .lineLimit(1)
                }
            }
            .padding(.leading, setBottomPanelHidden ? 8 : 0)
            .overlay(alignment: .leading) {
                if setBottomPanelHidden {
                    Color.Shape.primary
                        .frame(width: .onePixel)
                }
            }
            
            Button {
                onTapAddObject()
            } label: {
                Image(asset: .X24.attachment)
                    .foregroundColor(colors.inputAction)
            }
            .frame(height: 56)
            
            if hasAdditionalData || !text.string.isEmpty {
                Button {
                    onTapSend()
                } label: {
                    Image(asset: .X32.sendMessage)
                        .foregroundColor(colors.inputPrimaryAction)
                }
                .frame(height: 56)
            }
        }
        .padding(.horizontal, 12)
        .background(colors.inputBackground1Layer)
        .cornerRadius(16, style: .continuous)
        .padding(.horizontal, 32)
        .padding(.bottom, 12)
        .background(colors.inputAreaBackground)
    }
}

#Preview {
    DiscusionInput(text: .constant(NSAttributedString()), editing: .constant(false), mention: .constant(.finish), hasAdditionalData: true, onTapAddObject: {}, onTapSend: {})
}
