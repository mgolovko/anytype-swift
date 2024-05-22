import Foundation
import SwiftUI

struct HomeBottomPanelContainerExperemental<Content: View, BottomContent: View, Sheet: View>: View {

    @State private var bottomPanelHidden = false

    private var content: Content
    private var sheet: Sheet
    private var bottomPanel: BottomContent
    @Binding private var path: HomePath
    @State private var bottomSize: CGSize = .zero
    @Binding private var sheetDismiss: Bool

    init(
        path: Binding<HomePath>,
        sheetDismiss: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder sheet: () -> Sheet,
        @ViewBuilder bottomPanel: () -> BottomContent
    ) {
        self._path = path
        self._sheetDismiss = sheetDismiss
        self.content = content()
        self.sheet = sheet()
        self.bottomPanel = bottomPanel()
    }

    var body: some View {
        ZStack {
            // Fix size for initial state whe content is empty
            Spacer()
            content
            HomeBottomSheetContainer(path: path, sheetDismiss: $sheetDismiss) {
                sheet
            }
        }
        .anytypeNavigationPanelSize(bottomSize)
        .onChange(of: path.count) { newValue in
            withAnimation {
                bottomPanelHidden = false
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !bottomPanelHidden {
                VStack(spacing: 0) {
                    bottomPanel
                        .readSize {
                            bottomSize = $0
                        }
                        .transition(.opacity)
                    if path.count > 0 && sheetDismiss {
                        Spacer.fixedHeight(50)
                    }
                }
            }
        }
        .setHomeBottomPanelHiddenHandler($bottomPanelHidden)
        .ignoresSafeArea(.keyboard)
    }
}
