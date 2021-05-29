import Foundation
import SwiftUI


class MainAuthViewModel: ObservableObject {
    private let localRepoService = ServiceLocator.shared.localRepoService()
    private let authService = ServiceLocator.shared.authService()
    
    var error: String = "" {
        didSet {
            if !error.isEmpty {
                isShowingError = true
            }
        }
    }
    @Published var isShowingError: Bool = false
    @Published var showSignUpFlow: Bool = false
    
    func singUp() {
        authService.createWallet(in: localRepoService.middlewareRepoPath) { [weak self] result in
            switch result {
            case .failure(let error):
                // TODO: handel error
                self?.error = error.localizedDescription
            case .success:
                self?.showSignUpFlow = true
            }
        }
    }
    
    // MARK: - Coordinator
    func signUpFlow() -> some View {
        return AlphaInviteCodeView(signUpData: SignUpData())
    }
    
    func loginView() -> some View {
        return LoginView(viewModel: LoginViewModel())
    }
}
