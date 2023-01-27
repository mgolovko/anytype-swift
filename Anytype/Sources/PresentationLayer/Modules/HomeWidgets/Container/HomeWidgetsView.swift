import Foundation
import SwiftUI

struct HomeWidgetsView: View {
    
    @ObservedObject var model: HomeWidgetsViewModel
    
    var body: some View {
        ZStack {
            Gradients.widgetsBackground()
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(model.models, id: \.componentId) { model in
                        model.view
                    }
                    HomeEditButton(text: Loc.Widgets.Actions.editWidgets) {
                        model.onEditButtonTap()
                    }
                    .opacity(model.hideEditButton ? 0 : 1)
                    .animation(.default, value: model.hideEditButton)
                    Button("Show old home") {
                        model.onDisableNewHomeTap()
                    }
                    Button("Edit space icon") {
                        model.onSpaceIconChangeTap()
                    }
                    if #available(iOS 15.0, *) {} else {
                        // For safeAreaInsetLegacy
                        Color.clear.frame(height: 72)
                    }
                }
                .padding(.horizontal, 20)
            }
            .animation(.default, value: model.models.count)
        }
        .safeAreaInsetLegacy(edge: .bottom, spacing: 20) {
            model.bottomPanelProvider.view
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
    }
}

struct HomeWidgetsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeWidgetsView(
            model: HomeWidgetsViewModel(
                widgetObject: HomeWidgetsObject(
                    objectId: "",
                    objectDetailsStorage: DI.preview.serviceLocator.objectDetailsStorage()
                ),
                registry: DI.preview.widgetsDI.homeWidgetsRegistry(stateManager: HomeWidgetsStateManager(), widgetOutput: nil),
                blockWidgetService: DI.preview.serviceLocator.blockWidgetService(),
                accountManager: DI.preview.serviceLocator.accountManager(),
                bottomPanelProviderAssembly: DI.preview.widgetsDI.bottomPanelProviderAssembly(output: nil),
                toastPresenter: DI.preview.uihelpersDI.toastPresenter(),
                stateManager: HomeWidgetsStateManager(),
                output: nil
            )
        )
    }
}