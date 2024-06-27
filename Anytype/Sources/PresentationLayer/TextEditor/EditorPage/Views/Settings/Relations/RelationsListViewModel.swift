import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore
import Combine

@MainActor
final class RelationsListViewModel: ObservableObject {
        
    @Published private(set) var navigationBarButtonsDisabled: Bool = false
    @Published var sections = [RelationsSection]()
    
    // MARK: - Private variables
    
    private let document: any BaseDocumentProtocol
    private let sectionsBuilder = RelationsSectionBuilder()
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
    private weak var output: (any RelationsListModuleOutput)?
    
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - Initializers
    
    init(
        document: some BaseDocumentProtocol,
        output: (any RelationsListModuleOutput)?
    ) {
        self.document = document
        self.output = output
        
        document.parsedRelationsPublisher
            .map { [sectionsBuilder] relations in
                sectionsBuilder.buildSections(
                    from: relations,
                    objectTypeName: document.details?.objectType.name ?? ""
                )
            }
            .receiveOnMain()
            .assign(to: &$sections)
        
        document.permissionsPublisher
            .receiveOnMain()
            .sink { [weak self] permissions in
                guard let self else { return }
                navigationBarButtonsDisabled = !permissions.canEditRelationsList
            }
            .store(in: &subscriptions)
    }
    
}

// MARK: - Internal functions

extension RelationsListViewModel {
    
    func changeRelationFeaturedState(relation: Relation, addedToObject: Bool) {
        if !addedToObject {
            Task { @MainActor in
                try await relationsService.addRelations(objectId: document.objectId, relationKeys: [relation.key])
                changeRelationFeaturedState(relation: relation)
            }
        } else {
            changeRelationFeaturedState(relation: relation)
        }
    }
    
    private func changeRelationFeaturedState(relation: Relation) {
        Task {
            if relation.isFeatured {
                AnytypeAnalytics.instance().logUnfeatureRelation(spaceId: document.spaceId)
                try await relationsService.removeFeaturedRelation(objectId: document.objectId, relationKey: relation.key)
            } else {
                AnytypeAnalytics.instance().logFeatureRelation(spaceId: document.spaceId)
                try await relationsService.addFeaturedRelation(objectId: document.objectId, relationKey: relation.key)
            }
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func handleTapOnRelation(relation: Relation) {
        output?.editRelationValueAction(document: document, relationKey: relation.key)
    }
    
    func removeRelation(relation: Relation) {
        Task {
            try await relationsService.removeRelation(objectId: document.objectId, relationKey: relation.key)
            let relationDetails = try relationDetailsStorage.relationsDetails(for: relation.key, spaceId: document.spaceId)
            AnytypeAnalytics.instance().logDeleteRelation(spaceId: document.spaceId, format: relationDetails.format, key: relationDetails.analyticsKey)
        }
    }
    
    func showAddNewRelationView() {
        output?.addNewRelationAction(document: document)
    }
    
}
