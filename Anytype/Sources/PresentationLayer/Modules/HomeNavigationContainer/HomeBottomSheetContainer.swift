import Foundation
import SwiftUI

struct HomeBottomSheetContainer<Content: View>: View {
    
    private var content: Content
    private var path: HomePath
    
    @Binding private var sheetDismiss: Bool
    @State private var sheetDragOffsetY: CGFloat = 0
    @State private var dragInProgress = false
    @GestureState private var dragGestureActive: Bool = false
    
    init(
        path: HomePath,
        sheetDismiss: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.path = path
        self._sheetDismiss = sheetDismiss
        self.content = content()
    }
    
//    var body: some View {
//        ZStack {
//            if path.count > 0 {
//                sheetContainer
//                    .transition(.move(edge: .bottom))
//            }
//        }
//        .animation(.default, value: path.count)
//        .animation(.default, value: sheetDismiss)
//        .onChange(of: path.count) { newValue in
//            if sheetDismiss {
//                sheetDismiss = false
//            }
//        }
//    }
    
    var body: some View {
        GeometryReader { readerSafeArea in
            GeometryReader { readerFrame in
                if path.count > 0 {
                    ZStack {
//                        Color.red
                        content
//                            .allowsHitTesting(!sheetDismiss)
                    }
//                    .disabled(false)
                    .frame(height: readerFrame.size.height - readerSafeArea.safeAreaInsets.top - 10)
                    .cornerRadius(16, style: .continuous)
                    .shadow(radius: 5)
                    .offset(y: (sheetDismiss ? readerFrame.size.height - 50 : readerSafeArea.safeAreaInsets.top + 10) + (dragInProgress ? sheetDragOffsetY : 0))
                    .highPriorityGesture(
                        DragGesture()
                            .updating($dragGestureActive) { value, state, transaction in
                                state = true
                            }
                            .onChanged { value in
                                sheetDragOffsetY = value.translation.height
                                dragInProgress = true
                            }
                            .onEnded { value in
                                withAnimation {
                                    // TODO: Sync with offset - move to methods
                                    let hide = readerFrame.size.height - 50
                                    let show = readerSafeArea.safeAreaInsets.top + 10
                                    
                                    let distance = hide - show
                                    let distanceForChange = distance * 0.3
                                    if sheetDragOffsetY > 0 && abs(sheetDragOffsetY) > distanceForChange {
                                        // Down
                                        sheetDismiss = true
                                    } else if sheetDragOffsetY < 0 && abs(sheetDragOffsetY) > distanceForChange {
                                        // Up
                                        sheetDismiss = false
                                    }
                                    
                                    sheetDragOffsetY = 0
                                    dragInProgress = false
                                }
                            }
                    )
                    .onChange(of: dragGestureActive) { newState in
                        // Some times drag gesture call on change and don't call on end. Detect cancel gesture
                        if newState == false {
                            sheetDragOffsetY = 0
                            dragInProgress = false
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .ignoresSafeArea()
        }
        .animation(.default, value: path.count)
        .animation(.default, value: sheetDismiss)
        .onChange(of: path.count) { newValue in
            if sheetDismiss {
                sheetDismiss = false
            }
        }
    }
}
