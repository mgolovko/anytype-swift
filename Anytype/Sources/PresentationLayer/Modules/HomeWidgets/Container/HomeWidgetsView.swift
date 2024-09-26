import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeWidgetsView: View {
    let info: AccountInfo
    let output: (any HomeWidgetsModuleOutput)?
    
    var body: some View {
        HomeWidgetsInternalView(info: info, output: output)
            .id(info.hashValue)
    }
}

private struct HomeWidgetsInternalView: View {
    @StateObject private var model: HomeWidgetsViewModel
    @State var dndState = DragState()
    
    init(info: AccountInfo, output: (any HomeWidgetsModuleOutput)?) {
        self._model = StateObject(wrappedValue: HomeWidgetsViewModel(info: info, output: output))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geo in
                DashboardWallpaper(wallpaper: model.wallpaper, spaceIcon: model.space?.iconImage)
                    .frame(width: geo.size.width)
                    .clipped()
                    .ignoresSafeArea()
            }
            
//            TabView(selection: $model.experementalState) {
//                chatView
//                    .tag(HomeWidgetsExperementalState.chat)
//                
//                widgetsView
//                    .tag(HomeWidgetsExperementalState.widgets)
//            }
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            .transition(.slide)
//            .animation(.default, value: model.experementalState)
            
            chatView
                .opacity(model.experementalState == .chat ? 0 : 1)
            
            widgetsView
                .opacity(model.experementalState == .widgets ? 0 : 1)
            
//            switch model.experementalState {
//            case .chat:
//                chatView
//                    .transition(.opacity)
////                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)).combined(with: .opacity))
//                    .id("cv")
//            case .widgets:
//                widgetsView
//                    .transition(.opacity)
////                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)).combined(with: .opacity))
//                    .id("ww")
//            }
            
            HomeBottomPanelView(homeState: $model.homeState) {
                model.onCreateWidgetFromEditMode()
            }
        }
        
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeSpaceExperementView2(spaceId: model.spaceId, state: $model.experementalState)
                .background(Color.Navigation.background)
                .background(.ultraThinMaterial)
        }
        .throwingTask {
            try await model.fetchChatObject()
        }
        .task {
            await model.startWidgetObjectTask()
        }
        .task {
            await model.startParticipantTask()
        }
        .onAppear {
            model.onAppear()
        }
        .navigationBarHidden(true)
        .anytypeStatusBar(style: .lightContent)
        .anytypeVerticalDrop(data: model.widgetBlocks, state: $dndState) { from, to in
            model.dropUpdate(from: from, to: to)
        } dropFinish: { from, to in
            model.dropFinish(from: from, to: to)
        }
    }
    
    private var editButtons: some View {
        EqualFitWidthHStack(spacing: 12) {
            HomeEditButton(text: Loc.Widgets.Actions.addWidget, homeState: model.homeState) {
                model.onCreateWidgetFromMainMode()
            }
            HomeEditButton(text: Loc.Widgets.Actions.editWidgets, homeState: model.homeState) {
                model.onEditButtonTap()
            }
        }
    }
    
    private var widgetsView: some View {
        VerticalScrollViewWithOverlayHeader {
            HomeTopShadow()
        } content: {
            VStack(spacing: 12) {
                if model.dataLoaded {
//                    HomeSpaceExperementView(spaceId: model.spaceId, state: $model.experementalState)
                    HomeUpdateSubmoduleView()
                    SpaceWidgetView(spaceId: model.spaceId) {
                        model.onSpaceSelected()
                    }
                    if FeatureFlags.allContent {
                        AllContentWidgetView(
                            spaceId: model.spaceId,
                            homeState: $model.homeState,
                            output: model.output
                        )
                    }
                    if #available(iOS 17.0, *) {
                        WidgetSwipeTipView()
                    }
                    ForEach(model.widgetBlocks) { widgetInfo in
                        HomeWidgetSubmoduleView(
                            widgetInfo: widgetInfo,
                            widgetObject: model.widgetObject,
                            workspaceInfo: model.info,
                            homeState: $model.homeState,
                            output: model.output
                        )
                    }
                    if !FeatureFlags.allContent {
                        BinLinkWidgetView(spaceId: model.spaceId, homeState: $model.homeState, output: model.submoduleOutput())
                    }
                    editButtons
                }
                AnytypeNavigationSpacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .fitIPadToReadableContentGuide()
        }
        .animation(.default, value: model.widgetBlocks.count)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .homeBottomPanelHidden(model.homeState.isEditWidgets)
    }
    
    private var chatView: some View {
        VStack(spacing: 0) {
//            HomeSpaceExperementView(spaceId: model.spaceId, state: $model.experementalState)
//                .padding(.horizontal, 20)
            if let chatData = model.chatData {
                DiscussionCoordinatorView(data: chatData)
//                    .background(Color.red)
                    .environment(\.discussionColorTheme, .home)
                    .environment(\.discussionSettings, DiscussionSetings(showHeader: false))
            }
        }
//        .padding(.top, 12)
        .fitIPadToReadableContentGuide()
        .homeBottomPanelHidden(true)
    }
}
