import SwiftUI
import AnytypeCore
import Services

struct HomeWidgetsCoordinatorView: View {
    
    @StateObject private var model: HomeWidgetsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(spaceInfo: AccountInfo) {
        self._model = StateObject(wrappedValue: HomeWidgetsCoordinatorViewModel(spaceInfo: spaceInfo))
    }
    
    var body: some View {
        HomeWidgetsView(info: model.spaceInfo, output: model)
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .sheet(item: $model.showChangeSourceData) {
                WidgetChangeSourceSearchView(data: $0) {
                    model.onFinishChangeSource(screenData: $0)
                }
            }
            .sheet(item: $model.showChangeTypeData) {
                WidgetTypeChangeView(data: $0)
            }
            .sheet(item: $model.showCreateWidgetData) {
                CreateWidgetCoordinatorView(data: $0) {
                    model.onFinishCreateSource(screenData: $0)
                }
            }
            .sheet(item: $model.showSpaceSettingsData) {
                SpaceSettingsCoordinatorView(workspaceInfo: $0)
            }
    }
}
