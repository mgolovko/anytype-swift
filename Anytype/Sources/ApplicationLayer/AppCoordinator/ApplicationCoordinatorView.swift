import Foundation
import SwiftUI

struct ApplicationCoordinatorView: View {
    
    @StateObject var model: ApplicationCoordinatorViewModel
    
    var body: some View {
        Group {
            applicationView
        }
        .onAppear {
            model.onAppear()
        }
        .snackbar(toastBarData: $model.toastBarData)
    }
    
    @ViewBuilder
    var applicationView: some View {
        switch model.applicationState {
        case .initial:
            model.initialView()
        case .auth:
            model.authView()
                .preferredColorScheme(.dark)
        case .login:
            LaunchView()
        case .home:
            model.homeView()
        case .delete:
            model.deleteAccount()
        }
    }
}
