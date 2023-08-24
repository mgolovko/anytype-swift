import Foundation
import Services
import AnytypeCore

final class ObjectTypesSearchInteractor {
    
    private let spaceId: String
    private let searchService: SearchServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let excludedObjectTypeId: String?
    private let showBookmark: Bool
    private let showSetAndCollection: Bool
    
    init(
        spaceId: String,
        searchService: SearchServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        excludedObjectTypeId: String?,
        showBookmark: Bool,
        showSetAndCollection: Bool
    ) {
        self.spaceId = spaceId
        self.searchService = searchService
        self.workspaceService = workspaceService
        self.excludedObjectTypeId = excludedObjectTypeId
        self.showBookmark = showBookmark
        self.showSetAndCollection = showSetAndCollection
    }
    
}

extension ObjectTypesSearchInteractor {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchObjectTypes(
            text: text,
            filteringTypeId: excludedObjectTypeId,
            shouldIncludeSets: showSetAndCollection,
            shouldIncludeCollections: showSetAndCollection,
            shouldIncludeBookmark: showBookmark,
            spaceId: spaceId
        )
    }
    
    func searchInMarketplace(text: String, excludedIds: [String]) async throws -> [ObjectDetails] {
        try await searchService.searchMarketplaceObjectTypes(text: text, excludedIds: excludedIds)
    }
    
    func installType(objectId: String) async throws -> ObjectDetails {
        try await workspaceService.installObject(spaceId: spaceId, objectId: objectId)
    }
}

