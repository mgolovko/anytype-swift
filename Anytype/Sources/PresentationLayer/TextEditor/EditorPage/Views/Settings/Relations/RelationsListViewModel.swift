import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class RelationsListViewModel: ObservableObject {
    
    // MARK: - Private variables
    
    @Published private(set) var sections: [RelationsSection]
    private let sectionsBuilder = RelationsSectionBuilder()
    private let relationsService: RelationsServiceProtocol = RelationsService()
    
    private let objectId: String
    private let onValueEditingTap: (String) -> ()
    
    // MARK: - Initializers
    
    init(
        objectId: String,
        sections: [RelationsSection] = [],
        onValueEditingTap: @escaping (String) -> ()
    ) {
        self.objectId = objectId
        self.sections = sections
        self.onValueEditingTap = onValueEditingTap
    }
    
    // MARK: - Internal functions
    
    func update(with parsedRelations: ParsedRelations) {
        self.sections = sectionsBuilder.buildSections(from: parsedRelations)
    }
    
    func changeRelationFeaturedState(relationId: String) {
        let relationsRowData: [Relation] = sections.flatMap { $0.relations }
        let relationRowData = relationsRowData.first { $0.id == relationId }
        
        guard let relationRowData = relationRowData else { return }
        
        if relationRowData.isFeatured {
            relationsService.removeFeaturedRelations(objectId: objectId, relationIds: [relationRowData.id])
        } else {
            relationsService.addFeaturedRelations(objectId: objectId, relationIds: [relationRowData.id])
        }
    }
    
    func removeRelation(id: String) {
        relationsService.removeRelation(objectId: objectId, relationId: id)
    }
    
    func editRelation(id: String) {
        onValueEditingTap(id)
    }
    
}
