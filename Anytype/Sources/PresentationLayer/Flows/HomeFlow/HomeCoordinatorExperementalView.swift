import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeCoordinatorExperementalView: View {
    
    @StateObject var model: HomeCoordinatorExperementalViewModel
    @Environment(\.keyboardDismiss) var keyboardDismiss
    
    var body: some View {
        HomeBottomPanelContainerExperemental(
            path: $model.editorPath,
            sheetDismiss: $model.sheetDismiss,
            content: {
                if let info = model.accountInfo {
                    model.homeWidgetsModule(info: info)
                }
            },
            sheet: {
                AnytypeNavigationView(path: $model.editorPath, pathChanging: $model.pathChanging) { builder in
                    builder.appendBuilder(for: EditorScreenData.self) { data in
                        model.editorModule(data: data)
                    }
                }
            },
            bottomPanel: {
                model.homeBottomNavigationPanelModule()
            }
        )
        .onAppear {
            model.onAppear()
        }
        .environment(\.pageNavigation, model.pageNavigation)
        .onChange(of: model.keyboardToggle) { _ in
            keyboardDismiss()
        }
        .snackbar(toastBarData: $model.toastBarData)
        .sheet(item: $model.showChangeSourceData) { data in
            model.changeSourceModule(data: data)
        }
        .sheet(item: $model.showChangeTypeData) { data in
            model.changeTypeModule(data: data)
        }
        .sheet(item: $model.showSearchData) { data in
            model.searchModule(data: data)
        }
        .sheet(item: $model.showCreateWidgetData) { data in
            model.createWidgetModule(data: data)
        }
        .sheet(isPresented: $model.showSpaceSwitch) {
            model.createSpaceSwitchModule()
        }
        .sheet(isPresented: $model.showSpaceSettings) {
            model.createSpaceSeetingsModule()
        }
        .sheet(isPresented: $model.showSharing) {
            model.createSharingModule()
        }
        .sheet(isPresented: $model.showTypeSearchForObjectCreation) {
            model.typeSearchForObjectCreationModule()
        }
        .anytypeSheet(item: $model.spaceJoinData) {
            model.spaceJoinModule(data: $0)
        }
        .if(FeatureFlags.galleryInstallation, if: {
            $0.sheet(item: $model.showGalleryImport) { data in
                GalleryInstallationCoordinatorView(data: data)
            }
        }, else: {
            $0.anytypeSheet(item: $model.showGalleryImport) { _ in
                GalleryUnavailableView()
            }
        })
    }
}

#Preview {
    DI.preview.coordinatorsDI.home().make()
}
