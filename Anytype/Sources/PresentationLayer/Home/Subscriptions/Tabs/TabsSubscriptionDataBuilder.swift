import Foundation
import BlocksModels

extension SubscriptionId {
    static var favoritesTab = SubscriptionId(value: "SubscriptionId.FavoritesTab")
    static var recentTab = SubscriptionId(value: "SubscriptionId.RecentTab")
    static var archiveTab = SubscriptionId(value: "SubscriptionId.ArchiveTab")
    static var sharedTab = SubscriptionId(value: "SubscriptionId.SharedTab")
    static var setsTab = SubscriptionId(value: "SubscriptionId.SetsTab")
}

final class TabsSubscriptionDataBuilder: TabsSubscriptionDataBuilderProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    private let accountManager: AccountManagerProtocol
    
    init(accountManager: AccountManagerProtocol) {
        self.accountManager = accountManager
    }
    
    // MARK: - TabsSubscriptionDataBuilderProtocol
    
    func build(for tab: HomeTabsView.Tab) -> SubscriptionData {
        switch tab {
        case .favourites:
            return favoritesTab()
        case .sets:
            return setsTab()
        case .shared:
            return sharedTab()
        case .recent:
            return recentTab()
        case .bin:
            return archiveTab()
        }
    }
    
    func allIds() -> [SubscriptionId] {
        return [.sharedTab, .setsTab, .archiveTab, .recentTab, .favoritesTab]
    }
    
    // MARK: - Private
    
    private func recentTab() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        var filters = buildFilters(
            isArchived: false,
            layouts: DetailsLayout.visibleLayouts
        )
        filters.append(SearchHelper.lastOpenedDateNotNilFilter())
        
        return .search(
            SubscriptionData.Search(
                identifier: SubscriptionId.recentTab,
                sorts: [sort],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: homeDetailsKeys
            )
        )
    }
    
    private func archiveTab() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters = buildFilters(
            isArchived: true,
            layouts: DetailsLayout.visibleLayouts
        )
        
        return .search(
            SubscriptionData.Search(
                identifier: SubscriptionId.archiveTab,
                sorts: [sort],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: homeDetailsKeys
            )
        )
    }
    
    private func sharedTab() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        var filters = buildFilters(isArchived: false, layouts: DetailsLayout.visibleLayouts)
        filters.append(contentsOf: SearchHelper.sharedObjectsFilters())
        
        return .search(
            SubscriptionData.Search(
                identifier: SubscriptionId.sharedTab,
                sorts: [sort],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: homeDetailsKeys
            )
        )
    }
    
    private func setsTab() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        let filters = buildFilters(
            isArchived: false,
            layouts: [DetailsLayout.set]
        )
        
        return .search(
            SubscriptionData.Search(
                identifier: SubscriptionId.setsTab,
                sorts: [sort],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: homeDetailsKeys
            )
        )
    }
    
    private func favoritesTab() -> SubscriptionData {
        var filters = buildFilters(isArchived: false, layouts: DetailsLayout.visibleLayouts)
        filters.append(SearchHelper.isFavoriteFilter(isFavorite: true))
        
        return .search(
            SubscriptionData.Search(
                identifier: SubscriptionId.favoritesTab,
                sorts: [],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: homeDetailsKeys
            )
        )
    }

    
    private var homeDetailsKeys: [String] {
        let keys: [BundledRelationKey] = [
            .id,
            .iconEmoji,
            .iconImage,
            .name,
            .snippet,
            .description,
            .type,
            .layout,
            .isArchived,
            .isDeleted,
            .done,
            .isFavorite
        ]
        return keys.map { $0.rawValue }
    }
    
    private func buildFilters(isArchived: Bool) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            SearchHelper.workspaceId(accountManager.account.info.accountSpaceId),
        ]
    }
    
    private func buildFilters(isArchived: Bool, layouts: [DetailsLayout]) -> [DataviewFilter] {
        var filters = buildFilters(isArchived: isArchived)
        filters.append(SearchHelper.layoutFilter(layouts))
        return filters
    }
}
