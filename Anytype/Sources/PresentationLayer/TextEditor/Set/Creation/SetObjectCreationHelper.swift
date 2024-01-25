import Services
import AnytypeCore

struct SetObjectCreationResult {
    let details: ObjectDetails?
    let titleInputType: CreateObjectTitleInputType
}

protocol SetObjectCreationHelperProtocol {
    func createObject(
        for setDocument: SetDocumentProtocol, setting: ObjectCreationSetting?
    ) async throws -> SetObjectCreationResult
}

final class SetObjectCreationHelper: SetObjectCreationHelperProtocol {
    
    private let dataviewService: DataviewServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let prefilledFieldsBuilder: SetPrefilledFieldsBuilderProtocol
    private let blockActionsService: BlockListServiceProtocol
    
    init(
        objectTypeProvider: ObjectTypeProviderProtocol,
        dataviewService: DataviewServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        prefilledFieldsBuilder: SetPrefilledFieldsBuilderProtocol,
        blockActionsService: BlockListServiceProtocol
    ) {
        self.objectTypeProvider = objectTypeProvider
        self.dataviewService = dataviewService
        self.objectActionsService = objectActionsService
        self.prefilledFieldsBuilder = prefilledFieldsBuilder
        self.blockActionsService = blockActionsService
    }
    
    // MARK: - SetObjectCreationHelperProtocol
    
    func createObject(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> SetObjectCreationResult {
        if isBookmarkObject(setDocument: setDocument, setting: setting) {
            return .init(details: nil, titleInputType: .none)
        } else if setDocument.isCollection() {
            return try await createObjectForCollection(for: setDocument, setting: setting)
        } else if setDocument.isRelationsSet() {
            return try await createObjectForRelationSet(for: setDocument, setting: setting)
        } else {
            return try await  createObjectForRegularSet(for: setDocument, setting: setting)
        }
    }
    
    // MARK: - Private
    
    private func createObjectForCollection(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> SetObjectCreationResult {
        let objectType = objectType(for: setDocument, setting: setting)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
        
        let result = try await createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: [],
            templateId: templateId
        )
        try await objectActionsService.addObjectsToCollection(
            contextId: setDocument.objectId,
            objectIds: [result.details?.id].compactMap { $0 }
        )
        
        return result
    }
    
    private func createObjectForRelationSet(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> SetObjectCreationResult {
        let relationsDetails = setDocument.dataViewRelationsDetails.filter { detail in
            guard let source = setDocument.details?.setOf else { return false }
            return source.contains(detail.id)
        }
        let objectType = objectType(for: setDocument, setting: setting)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
        
        return try await createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: relationsDetails,
            templateId: templateId
        )
    }
    
    private func createObjectForRegularSet(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> SetObjectCreationResult {
        let objectTypeId = setDocument.details?.setOf.first ?? ""
        let objectType = try? objectTypeProvider.objectType(id: objectTypeId)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
        return try await createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: [],
            templateId: templateId
        )
    }
    
    private func createObject(
        setDocument: SetDocumentProtocol,
        type: ObjectType?,
        relationsDetails: [RelationDetails],
        templateId: BlockId?
    ) async throws -> SetObjectCreationResult {
        let details = try await dataviewService.addRecord(
            typeUniqueKey: type?.uniqueKey,
            templateId: templateId ?? "",
            spaceId: setDocument.spaceId,
            details: prefilledFieldsBuilder.buildPrefilledFields(from: setDocument.activeViewFilters, relationsDetails: relationsDetails)
        )
        let isNote = FeatureFlags.setTextInFirstNoteBlock && (type?.isNoteLayout ?? false)
        if isNote {
            guard let newBlockId = try await blockActionsService.add(contextId: details.id, targetId: EditorConstants.headerBlockId.rawValue, info: .emptyText, position: .bottom) else {
                return .init(details: details, titleInputType: .none)
            }
            
            return .init(details:details, titleInputType: .writeToBlock(blockId: newBlockId))
        } else {
            return .init(details:details, titleInputType: .writeToRelationName)
        }
    }
    
    private func isBookmarkObject(setDocument: SetDocumentProtocol, setting: ObjectCreationSetting?) -> Bool {
        if setDocument.isBookmarksSet() {
            return true
        }
        
        if let objectType = objectType(for: setDocument, setting: setting) {
            return objectType.recommendedLayout == .bookmark
        }
        
        return false
    }
    
    private func objectType(for setDocument: SetDocumentProtocol, setting: ObjectCreationSetting?) -> ObjectType? {
        let settingsObjectType = setting.map { try? objectTypeProvider.objectType(id: $0.objectTypeId) }
        let objectType = settingsObjectType ?? (try? setDocument.defaultObjectTypeForActiveView())
        return objectType
    }
    
    private func defaultTemplateId(for objectType: ObjectType?, setDocument: SetDocumentProtocol) -> String {
        if let defaultTemplateId = setDocument.activeView.defaultTemplateID, defaultTemplateId.isNotEmpty {
            return defaultTemplateId
        } else {
            return objectType?.defaultTemplateId ?? ""
        }
    }
}

extension SetObjectCreationHelperProtocol {
    func createObject(for setDocument: SetDocumentProtocol) async throws -> SetObjectCreationResult {
        return try await createObject(for: setDocument, setting: nil)
    }
}
