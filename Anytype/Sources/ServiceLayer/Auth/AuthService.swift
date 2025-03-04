import Foundation
import Combine
import SwiftUI
import ProtobufMessages
import Services
import AnytypeCore

final class AuthService: AuthServiceProtocol {
    
    @Injected(\.localRepoService)
    private var localRepoService: any LocalRepoServiceProtocol
    @Injected(\.loginStateService)
    private var loginStateService: any LoginStateServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.appErrorLoggerConfiguration)
    private var appErrorLoggerConfiguration: any AppErrorLoggerConfigurationProtocol
    @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: any ServerConfigurationStorageProtocol
    @Injected(\.authMiddleService)
    private var authMiddleService: any AuthMiddleServiceProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol

    private lazy var rootPath: String = {
        localRepoService.middlewareRepoPath
    }()
    
    func logout(removeData: Bool) async throws  {
        try await authMiddleService.logout(removeData: removeData)
        await loginStateService.cleanStateAfterLogout()
    }

    func createWallet() async throws -> String {
        try await authMiddleService.createWallet(rootPath: rootPath)
    }

    func createAccount(name: String, iconOption: Int, imagePath: String) async throws -> AccountData {
        let start = CFAbsoluteTimeGetCurrent()
        
        await loginStateService.setupStateBeforeLoginOrAuth()
        
        let account = try await authMiddleService.createAccount(
            name: name,
            imagePath: imagePath,
            iconOption: iconOption,
            networkMode: serverConfigurationStorage.currentConfiguration().middlewareNetworkMode,
            configPath: serverConfigurationStorage.currentConfigurationPath()?.path ?? ""
        )

        let middleTime = Int(((CFAbsoluteTimeGetCurrent() - start) * 1_000)) // milliseconds
        
        let analyticsId = account.info.analyticsId
        await AnytypeAnalytics.instance().setUserId(analyticsId)
        await AnytypeAnalytics.instance().setNetworkId(account.info.networkId)
        AnytypeAnalytics.instance().logAccountCreate(analyticsId: analyticsId, middleTime: middleTime)
        AnytypeAnalytics.instance().logCreateSpace(route: .navigation)
        await appErrorLoggerConfiguration.setUserId(analyticsId)
        
        userDefaults.usersId = account.id
        
        accountManager.account = account
        
        await loginStateService.setupStateAfterRegistration(account: account)
        return account
    }
    
    func walletRecovery(mnemonic: String) async throws {
        try await authMiddleService.walletRecovery(rootPath: rootPath, mnemonic: mnemonic)
    }

    func accountRecover() async throws {
        try await authMiddleService.accountRecover()
        loginStateService.setupStateAfterAuth()
    }
    
    func selectAccount(id: String) async throws -> AccountData {
        await loginStateService.setupStateBeforeLoginOrAuth()
        
        let account = try await authMiddleService.selectAccount(
            id: id,
            rootPath: rootPath,
            networkMode: serverConfigurationStorage.currentConfiguration().middlewareNetworkMode,
            configPath: serverConfigurationStorage.currentConfigurationPath()?.path ?? ""
        )
        
        let analyticsId = account.info.analyticsId
        await AnytypeAnalytics.instance().setUserId(analyticsId)
        await AnytypeAnalytics.instance().setNetworkId(account.info.networkId)
        AnytypeAnalytics.instance().logAccountOpen(analyticsId: analyticsId)
        await appErrorLoggerConfiguration.setUserId(analyticsId)
        
        switch account.status {
        case .active, .pendingDeletion:
            await setupAccountData(account)
        case .deleted:
            await loginStateService.cleanStateAfterLogout()
        }
        
        return account
    }
    
    private func setupAccountData(_ account: AccountData) async {
        userDefaults.usersId = account.id
        accountManager.account = account
        await loginStateService.setupStateAfterLoginOrAuth(account: accountManager.account)
    }
    
    func deleteAccount() async throws -> AccountStatus {
        try await authMiddleService.deleteAccount()
    }
    
    func restoreAccount() async throws -> AccountStatus {
        try await authMiddleService.restoreAccount()
    }
    
    func mnemonicByEntropy(_ entropy: String) async throws -> String {
        try await authMiddleService.mnemonicByEntropy(entropy)
    }
}
