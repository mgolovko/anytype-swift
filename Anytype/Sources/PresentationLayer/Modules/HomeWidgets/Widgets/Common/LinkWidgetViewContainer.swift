import SwiftUI

struct LinkWidgetViewContainer<Content, MenuContent>: View where Content: View, MenuContent: View {
    
    let title: String
    let description: String?
    @Binding var isExpanded: Bool
    let isEditalbeMode: Bool
    let allowMenuContent: Bool
    let menu: () -> MenuContent
    let content: () -> Content
    let removeAction: (() -> Void)?
    
    init(
        title: String,
        description: String? = nil,
        isExpanded: Binding<Bool>,
        isEditalbeMode: Bool = false,
        allowMenuContent: Bool = false,
        @ViewBuilder menu: @escaping () -> MenuContent = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content,
        removeAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self._isExpanded = isExpanded
        self.isEditalbeMode = isEditalbeMode
        self.allowMenuContent = allowMenuContent
        self.menu = menu
        self.content = content
        self.removeAction = removeAction
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(6)
                header
                if !isExpanded {
                    Spacer.fixedHeight(6)
                } else {
                    content()
                        .allowsHitTesting(!isEditalbeMode)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                    Spacer.fixedHeight(16)
                }
            }
            .background(Color.Dashboard.card)
            .cornerRadius(16, style: .continuous)
            .contentShapeLegacy(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            removeButton
                .zIndex(1)
        }
        .animation(.default, value: isEditalbeMode)
    }
    
    // MARK: - Private
    
    private var header: some View {
        HStack(spacing: 0) {
            Spacer.fixedWidth(16)
            AnytypeText(title, style: .subheading, color: .Text.primary)
                .lineLimit(1)
                .layoutPriority(-1)
            descriptionView
            Spacer()
            menuButton
            arrowButton
            Spacer.fixedWidth(12)
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    private var descriptionView: some View {
        // TODO: Waiting designer. Fix description style and spacer after title.
        if let description {
            Spacer.fixedWidth(8)
            AnytypeText(description, style: .body, color: .Text.secondary)
                .lineLimit(1)
        }
    }
    
    private var arrowButton: some View {
        Button(action: {
            withAnimation {
                isExpanded = !isExpanded
            }
        }, label: {
            Image(asset: .Widget.collapse)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
        })
            .allowsHitTesting(!isEditalbeMode)
    }
    
    @ViewBuilder
    private var menuButton: some View {
        if isEditalbeMode, allowMenuContent {
            Menu {
                menu()
            } label: {
                Image(asset: .Widget.settings)
            }
            Spacer.fixedWidth(16)
        }
    }
    
    @ViewBuilder
    private var removeButton: some View {
        VStack {
            if isEditalbeMode, let removeAction {
                Button(action: {
                    removeAction()
                }, label: {
                    Image(asset: .Widget.remove)
                })
                .transition(.scale)
            }
        }
        .offset(x: 8, y: -8)
    }
}

struct LinkWidgetViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.black)
            VStack {
                LinkWidgetViewContainer(
                    title: "Name",
                    description: nil,
                    isExpanded: .constant(true),
                    isEditalbeMode: false
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Name",
                    description: "1",
                    isExpanded: .constant(false),
                    isEditalbeMode: false
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text",
                    description: nil,
                    isExpanded: .constant(false),
                    isEditalbeMode: false
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text very long text",
                    description: "1 111",
                    isExpanded: .constant(true),
                    isEditalbeMode: true
                ) {
                    Text("Content")
                }
            }
        }
    }
}