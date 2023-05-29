import SwiftUI
import Combine
import LocalAuthentication

class LoginViewModel: ObservableObject {
    private let authService = ServiceLocator.shared.authService()
    private lazy var cameraPermissionVerifier = CameraPermissionVerifier()
    private let seedService: SeedServiceProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    
    @Published var seed: String = ""
    @Published var showQrCodeView: Bool = false
    @Published var openSettingsURL = false
    @Published var error: String? {
        didSet {
            showError = false
            
            if error.isNotNil {
                showError = true
            }
        }
    }
    @Published var showError: Bool = false
    
    @Published var entropy: String = "" {
        didSet {
            onEntropySet()
        }
    }
    @Published var showSelectProfile = false
    @Published var showMigrationGuide = false
    @Published var focusOnTextField = true
    
    let canRestoreFromKeychain: Bool

    private var subscriptions = [AnyCancellable]()

    init(seedService: SeedServiceProtocol = ServiceLocator.shared.seedService(), applicationStateService: ApplicationStateServiceProtocol) {
        self.canRestoreFromKeychain = (try? seedService.obtainSeed()).isNotNil
        self.seedService = seedService
        self.applicationStateService = applicationStateService
    }
    
    func onEntropySet() {
        do {
            let seed = try authService.mnemonicByEntropy(entropy)
            self.seed = seed
            recoverWallet()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func recoverWallet() {
        recoverWallet(with: seed)
    }

    func onShowQRCodeTap() {
        cameraPermissionVerifier.cameraPermission
            .receiveOnMain()
            .sink { [unowned self] isGranted in
                if isGranted {
                    showQrCodeView = true
                } else {
                    openSettingsURL = true
                }
            }
            .store(in: &subscriptions)
    }

    func restoreFromkeychain() {
        LocalAuth.auth(reason: Loc.restoreSecretPhraseFromKeychain) { [unowned self] didComplete in
            guard didComplete,
                  let phrase = try? seedService.obtainSeed() else {
                return
            }

            recoverWallet(with: phrase)            
        }
    }
    
    @MainActor
    func selectProfileFlow() -> some View {
        let viewModel = SelectProfileViewModel(applicationStateService: applicationStateService, onShowMigrationGuide: { [weak self] in
            self?.focusOnTextField = false
            self?.showSelectProfile = false
            self?.showMigrationGuide = true
        })
        return SelectProfileView(viewModel: viewModel)
    }
    
    func migrationGuideFlow() -> some View {
        return MigrationGuideView()
            .onDisappear { [weak self] in
                self?.focusOnTextField = true
            }
    }

    private func recoverWallet(with string: String) {
        do {
            try authService.walletRecovery(mnemonic: string.trimmingCharacters(in: .whitespacesAndNewlines))
            try seedService.saveSeed(string)
            showSelectProfile = true
        } catch {
            self.error = error.localizedDescription
        }
    }
}
