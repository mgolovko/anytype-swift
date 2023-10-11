import Foundation
import Services
import Combine
import AnytypeCore

protocol FilesSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        syncStatus: FileSyncStatus,
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

final class FilesSubscriptionService: FilesSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionId = "Files-\(UUID().uuidString)"
    
    init(
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
        self.activeWorkspaceStorage = activeWorkspaceStorage
    }
    
    // MARK: - FilesSubscriptionServiceProtocol
    
    func startSubscription(
        syncStatus: FileSyncStatus,
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.sizeInBytes,
            type: .desc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.spaceId(activeWorkspaceStorage.workspaceInfo.accountSpaceId),
            SearchHelper.layoutFilter([DetailsLayout.file, DetailsLayout.image]),
            SearchHelper.fileSyncStatus(syncStatus)
        ]
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: objectLimit ?? Constants.limit,
                offset: 0,
                keys: .builder {
                    BundledRelationKey.objectListKeys.map { $0.rawValue }
                    BundledRelationKey.sizeInBytes.rawValue
                }
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { [weak self] in
            guard let self else { return }
            update(subscriptionStorage.items)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
