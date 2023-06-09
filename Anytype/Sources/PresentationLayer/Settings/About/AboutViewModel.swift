import Foundation
import AnytypeCore
import UIKit
import DeviceKit
import AudioToolbox

@MainActor
final class AboutViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol
    private let accountManager: AccountManagerProtocol
    private weak var output: AboutModuleOutput?
    
    private var appVersion: String? = MetadataProvider.appVersion
    private var buildNumber: String? = MetadataProvider.buildNumber
    
    // MARK: - State
    
    @Published var info: String = ""
    @Published var snackBarData = ToastBarData.empty
    
    init(
        middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol,
        accountManager: AccountManagerProtocol,
        output: AboutModuleOutput?
    ) {
        self.middlewareConfigurationProvider = middlewareConfigurationProvider
        self.accountManager = accountManager
        self.output = output
        setupView()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logAboutSettingsShow()
    }
    
    func onWhatsNewTap() {
        AnytypeAnalytics.instance().logHelpAndCommunity(type: .whatIsNew)
        handleUrl(string: AboutApp.whatsNewLink)
    }
    
    func onCommunityTap() {
        AnytypeAnalytics.instance().logHelpAndCommunity(type: .anytypeCommunity)
        handleUrl(string: AboutApp.communityLink)
    }
    
    func onHelpTap() {
        AnytypeAnalytics.instance().logHelpAndCommunity(type: .helpAndTutorials)
        handleUrl(string: AboutApp.helpLink)
    }
    
    func onContactTap() {
        AnytypeAnalytics.instance().logHelpAndCommunity(type: .contactUs)
        let mailLink = MailUrl(
            to: AboutApp.mailTo,
            subject: Loc.About.Mail.subject(accountManager.account.id),
            body: Loc.About.Mail.body(fullInfo())
        )
        guard let mailLinkString = mailLink.string else { return }
        handleUrl(string: mailLinkString)
    }
    
    func onTermOfUseTap() {
        AnytypeAnalytics.instance().logLegal(type: .termsOfUse)
        handleUrl(string: AboutApp.termsLink)
    }
    
    func onPrivacyPolicyTap() {
        AnytypeAnalytics.instance().logLegal(type: .privacyPolicy)
        handleUrl(string: AboutApp.privacyLink)
    }
    
    func onInfoTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = fullInfo()
        snackBarData = .init(text: Loc.copiedToClipboard(Loc.About.techInfo), showSnackBar: true)
    }
    
    func onDebugMenuTap() {
        AudioServicesPlaySystemSound(1109)
        output?.onDebugMenuSelected()
    }
    
    // MARK: - Private
    
    private func setupView() {
        Task { @MainActor in
            let libraryVersion = try? await middlewareConfigurationProvider.libraryVersion()
            
            info = [
                Loc.About.appVersion(appVersion ?? ""),
                Loc.About.buildNumber(buildNumber ?? ""),
                Loc.About.library(libraryVersion ?? ""),
                Loc.About.accountId(accountManager.account.id),
                Loc.About.analyticsId(accountManager.account.info.analyticsId)
            ].joined(separator: "\n")
        }
    }
    
    private func handleUrl(string: String) {
        guard let url = URL(string: string) else { return }
        output?.onLinkOpen(url: url)
    }
    
    private func fullInfo() -> String {
        return [
            Loc.About.device(Device.current.safeDescription),
            Loc.About.osVersion(UIDevice.current.systemVersion),
            info
        ].joined(separator: "\n")
    }
}