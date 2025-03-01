import Foundation
import Services
import Combine
import AnytypeCore

protocol TemplatesSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        objectType: String,
        spaceId: String,
        update: @escaping ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

actor TemplatesSubscriptionService: TemplatesSubscriptionServiceProtocol {
    private let subscriptionId = "Templates-\(UUID().uuidString)"
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    func startSubscription(
        objectType: String,
        spaceId: String,
        update: @escaping ([ObjectDetails]) -> Void
    ) async {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.addedDate,
            type: .desc
        )
        let filters = SearchHelper.templatesFilters(type: objectType)
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
                sorts: [sort],
                filters: filters,
                limit: 100,
                offset: 0,
                keys: BundledRelationKey.templatePreviewKeys.map { $0.rawValue }
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            update(data.items)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
