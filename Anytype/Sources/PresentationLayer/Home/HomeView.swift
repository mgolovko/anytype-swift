import SwiftUI
import AnytypeCore

struct HomeView: View {
    @ObservedObject var model: HomeViewModel
    
    @StateObject private var settingsModel = SettingsViewModel(authService: ServiceLocator.shared.authService())
    
    @State var bottomSheetState = HomeBottomSheetViewState.closed
    @State private var showSettings = false
    @State private var showKeychainAlert = UserDefaultsConfig.showKeychainAlert
    @State private var isFirstLaunchAfterRegistration = ServiceLocator.shared.loginStateService().isFirstLaunchAfterRegistration

    var body: some View {
        navigationView
            .environment(\.font, .defaultAnytype)
            .environmentObject(model)
            .environmentObject(settingsModel)
            .onAppear {
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.homeShow)

                model.onAppear()
                
                UserDefaultsConfig.storeOpenedScreenData(nil)
            }
            .onDisappear {
                model.onDisappear()
            }
            .redacted(reason: model.loadingDocument ? .placeholder : [])
            .allowsHitTesting(!model.loadingDocument)
    }
    
    private var navigationView: some View {
        contentView
        .edgesIgnoringSafeArea(.all)
        .coordinateSpace(name: model.bottomSheetCoordinateSpaceName)

        .toolbar {
            ToolbarItem {
                Button(action: {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.fastSpring) {
                        showSettings.toggle()
                        if showSettings {
                            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.settingsShow)
                        }
                    }
                }) {
                    model.loadingDocument ? nil : Image(asset: .mainSettings)
                }
                .allowsHitTesting(!model.loadingDocument)
            }
        }
        .bottomFloater(isPresented: $showSettings) {
            SettingsView()
                .horizontalReadabilityPadding(8)
        }

        .bottomFloater(isPresented: $model.showPagesDeletionAlert) {
            DashboardDeletionAlert()
                .horizontalReadabilityPadding(8)
        }
        .animation(.fastSpring, value: model.showPagesDeletionAlert)
        
        .bottomSheet(isPresented: $settingsModel.personalization) {
            PersonalizationView()
                .horizontalReadabilityPadding(0)
        }
        .animation(.fastSpring, value: settingsModel.personalization)
        
        .bottomSheet(isPresented: $settingsModel.about) {
            AboutView()
                .horizontalReadabilityPadding(0)
        }
        .animation(.fastSpring, value: settingsModel.about)
        
        .bottomSheet(isPresented: $settingsModel.account) {
            SettingsAccountView()
                .horizontalReadabilityPadding(0)
        }
        .animation(.fastSpring, value: settingsModel.account)
        
        .bottomSheet(isPresented: $settingsModel.appearance) {
            SettingsAppearanceView()
                .horizontalReadabilityPadding(0)
        }
        .animation(.fastSpring, value: settingsModel.appearance)
        
        .bottomFloater(isPresented: $settingsModel.clearCacheAlert) {
            DashboardClearCacheAlert()
                .horizontalReadabilityPadding(8)
        }
        .animation(.fastSpring, value: settingsModel.clearCacheAlert)
        .onChange(of: settingsModel.clearCacheAlert) { showClearCacheAlert in
            if showClearCacheAlert {
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.clearFileCacheAlertShow)
            }
        }
        
        .bottomFloater(isPresented: $showKeychainAlert) {
            DashboardKeychainReminderAlert(shownInContext: isFirstLaunchAfterRegistration ? .signup : .settings)
                .horizontalReadabilityPadding(8)
        }
        .animation(.fastSpring, value: showKeychainAlert)
        .onChange(of: showKeychainAlert) {
            UserDefaultsConfig.showKeychainAlert = $0

            if isFirstLaunchAfterRegistration {
                AnytypeAnalytics.instance().logKeychainPhraseShow(.signup)
            }
        }
        
        .bottomFloater(isPresented: $model.loadingAlertData.showAlert) {
            DashboardLoadingAlert(text: model.loadingAlertData.text)
                .horizontalReadabilityPadding(8)
        }
        .animation(.fastSpring, value: model.loadingAlertData.showAlert)
        
        .sheet(isPresented: $model.showSearch) {
            HomeSearchView()
                .environmentObject(model)
                .onChange(of: model.showSearch) { showSearch in
                    AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.searchShow)
                }
        }   
        
        .bottomFloater(isPresented: $settingsModel.loggingOut) {
            DashboardLogoutAlert()
                .horizontalReadabilityPadding(8)
        }
        .animation(.fastSpring, value: settingsModel.loggingOut)
        
        
        .bottomFloater(isPresented: $settingsModel.accountDeleting) {
            DashboardAccountDeletionAlert()
                .horizontalReadabilityPadding(8)
        }
        .animation(.fastSpring, value: settingsModel.accountDeleting)
        
        .snackbar(
            isShowing: $model.snackBarData.showSnackBar,
            text: AnytypeText(model.snackBarData.text, style: .uxCalloutRegular, color: .textPrimary)
        )
        
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var contentView: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    DashboardWallpaper()
                    if let data = model.openedEditorScreenData {
                        newPageNavigation(data: data)
                    }
                    HomeProfileView()
                    
                    HomeBottomSheetView(containerHeight: geometry.size.height, state: $bottomSheetState) {
                        HomeTabsView(offsetChanged: offsetChanged, onDrag: onDrag, onDragEnd: onDragEnd)
                    }
                    DashboardSelectionActionsView()
                }.frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    private func newPageNavigation(data: EditorScreenData) -> some View {
        NavigationLink(isActive: $model.showingEditorScreenData) {
            model.createBrowser(data: data)
        } label: {
            EmptyView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel.makeForPreview())
    }
}
