import SwiftUI
import AnytypeCore
import Services


struct SpaceHubCoordinatorView: View {
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    @StateObject private var model = SpaceHubCoordinatorViewModel()
    
    var body: some View {
        content
            .onAppear {
                model.keyboardDismiss = keyboardDismiss
                model.dismissAllPresented = dismissAllPresented
            }
            .onChange(of: model.navigationPath) { _ in model.onPathChange() }
        
            .task { await model.setup() }
            
            .handleSpaceShareTip()
            .handleSharingTip()
            .handleSpaceHubTip()
            .updateShortcuts(spaceId: model.fallbackSpaceId)
            .snackbar(toastBarData: $model.toastBarData)
            
            .sheet(item: $model.sharingSpaceId) {
                ShareCoordinatorView(spaceId: $0.value)
            }
            .sheet(item: $model.showGalleryImport) { data in
                GalleryInstallationCoordinatorView(data: data)
            }
            .sheet(isPresented: $model.showSpaceManager) {
                SpacesManagerView()
            }
            .sheet(isPresented: $model.showSpaceShareTip) {
                SpaceShareTipView()
            }
            .sheet(item: $model.membershipTierId) { tierId in
                MembershipCoordinator(initialTierId: tierId.value)
            }
            .sheet(item: $model.showSpaceSwitchData) {
                SpaceSwitchCoordinatorView(data: $0)
            }
            .sheet(item: $model.membershipNameFinalizationData) {
                MembershipNameFinalizationView(tier: $0)
            }
            .sheet(item: $model.showGlobalSearchData) {
                GlobalSearchView(data: $0)
            }
            .sheet(item: $model.typeSearchForObjectCreationSpaceId) {
                model.typeSearchForObjectCreationModule(spaceId: $0.value)
            }
            .anytypeSheet(item: $model.spaceJoinData) {
                SpaceJoinView(data: $0, onManageSpaces: {
                    model.onManageSpacesSelected()
                })
            }
            .anytypeSheet(item: $model.userWarningAlert, dismissOnBackgroundView: false) {
                UserWarningAlertCoordinatorView(alert: $0)
            }
    }
    
    private var content: some View {  
        ZStack {
            NotificationCoordinatorView(sceneId: model.sceneId)
            
            HomeBottomPanelContainer(
                path: $model.navigationPath,
                content: {
                    AnytypeNavigationView(path: $model.navigationPath, pathChanging: $model.pathChanging) { builder in
                        builder.appendBuilder(for: AccountInfo.self) { info in
                            HomeTabBarCoordinatorView(spaceInfo: info)
                        }
                        builder.appendBuilder(for: EditorScreenData.self) { data in
                            EditorCoordinatorView(data: data)
                        }
                        builder.appendBuilder(for: SpaceHubNavigationItem.self) { _ in
                            SpaceHubView(sceneId: model.sceneId)
                        }
                    }
                },
                bottomPanel: {
                    if let spaceInfo = model.spaceInfo {
                        HomeBottomNavigationPanelView(homePath: model.navigationPath, info: spaceInfo, output: model)
                    }
                }
            )
        }
        .animation(.easeInOut, value: model.spaceInfo)
        .environment(\.pageNavigation, model.pageNavigation)
    }
}

#Preview {
    SpaceHubCoordinatorView()
}
