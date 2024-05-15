import Services
import Foundation


@MainActor
final class MembershipOwnerInfoSheetViewModel: ObservableObject {
    
    @Published var membership: MembershipStatus = .empty
    
    @Published var showMangeButton = false
    @Published var showManageSubscriptions = false
    @Published var showEmailVerification = false
    
    @Published var email: String = ""
    @Published var changeEmail = false
    @Published var toastData: ToastBarData = .empty
    
    // remove after middleware start to send update membership event
    @Published private var justUpdatedEmail = false
    var alreadyHaveEmail: Bool {
        membership.email.isNotEmpty || justUpdatedEmail
    }
    
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    @Injected(\.membershipMetadataProvider)
    private var metadataProvider: MembershipMetadataProviderProtocol
    
    init() {
        let storage = Container.shared.membershipStatusStorage.resolve()
        storage.statusPublisher.receiveOnMain().assign(to: &$membership)
    }
    
    func updateState() {
        Task {
            let purchaseType = await metadataProvider.purchaseType(status: membership)
            switch purchaseType {
            case .purchasedInAppStoreWithCurrentAccount:
                showMangeButton = true
            case .purchasedInAppStoreWithOtherAccount, .purchasedElsewhere:
                showMangeButton = false
            }
        }
    }
    
    func getVerificationEmail(email: String) async throws {
        try await membershipService.getVerificationEmail(email: email)
        self.email = email
        showEmailVerification = true
    }
    
    func onSuccessfullEmailVerification() {
        showEmailVerification = false
        changeEmail = false
        justUpdatedEmail = true
        toastData = ToastBarData(text: Loc.emailSuccessfullyValidated, showSnackBar: true)
    }
}
