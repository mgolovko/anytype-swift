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
        GeometryReader { reader in
            ZStack {
                Spacer()
                VStack {
                    content
                        .if(path.path.isNotEmpty) {
                            $0.clipShape( UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(bottomLeading: 8, bottomTrailing: 8), style: .continuous) )
                        }
                    if path.path.isNotEmpty {
                        Spacer.fixedHeight(94)
                    }
                }
                .ignoresSafeArea()
                
                HomeBottomSheetContainer(path: path, sheetDismiss: $sheetDismiss) {
                    sheet
                }
                
                
                if !bottomPanelHidden {
                    VStack {
                        Spacer()
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
                        Spacer.fixedHeight(8)
                    }
                }
            }
        }
        .background(Color.black)
        .anytypeNavigationPanelSize(bottomSize)
        .onChange(of: path.count) { newValue in
            withAnimation {
                bottomPanelHidden = false
            }
        }
//        .safeAreaInset(edge: .bottom) {
//            if !bottomPanelHidden {
//                VStack(spacing: 0) {
//                    bottomPanel
//                        .readSize {
//                            bottomSize = $0
//                        }
//                        .transition(.opacity)
//                    if path.count > 0 && sheetDismiss {
//                        Spacer.fixedHeight(50)
//                    }
//                }
//            }
//        }
        .setHomeBottomPanelHiddenHandler($bottomPanelHidden)
        .ignoresSafeArea(.keyboard)
    }
}
