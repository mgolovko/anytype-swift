import Foundation
import Services
import AnytypeCore

protocol SetPermissionsBuilderProtocol: AnyObject {
    func build(setDocument: SetDocument, participantCanEdit: Bool) -> SetPermissions
}

final class SetPermissionsBuilder: SetPermissionsBuilderProtocol {
    
    func build(setDocument: SetDocument, participantCanEdit: Bool) -> SetPermissions {
        
        let isVersionMode = setDocument.mode.isVersion
        let isArchive = setDocument.details?.isArchived ?? true
        let isLocked = setDocument.document.isLocked
        let canEdit = !isLocked && !isArchive && participantCanEdit && !isVersionMode
        
        return SetPermissions(
            canCreateObject: canEdit && canCreateObject(setDocument: setDocument, participantCanEdit: participantCanEdit),
            canEditView: canEdit,
            canTurnSetIntoCollection: canEdit && !setDocument.isCollection(),
            canChangeQuery: canEdit && !setDocument.isCollection(),
            canEditRelationValuesInView: canEdit && canEditRelationValuesInView(setDocument: setDocument),
            canEditTitle: canEdit,
            canEditDescription: canEdit,
            canEditSetObjectIcon: canEdit
        )
    }
    
    private func canCreateObject(setDocument: SetDocument, participantCanEdit: Bool) -> Bool {
        
        guard let details = setDocument.details else {
            anytypeAssertionFailure("SetDocument: No details in canCreateObject")
            return false
        }
        guard details.isList else { return false }
        
        if details.isCollection { return true }
        if setDocument.isSetByRelation() { return true }
        
        // Set query validation
        // Create objects in sets by type only permitted if type is Page-like
        guard let setOfId = details.filteredSetOf.first else {
            return false
        }
        
        guard let queryObject = try? ObjectTypeProvider.shared.objectType(id: setOfId) else {
            return false
        }
        
        if queryObject.uniqueKey == ObjectTypeUniqueKey.template {
            return false
        }
        
        guard let layout = queryObject.recommendedLayout else {
            return false
        }
        
        return DetailsLayout.supportedForCreationInSets.contains(layout)
    }
    
    private func canEditRelationValuesInView(setDocument: some SetDocumentProtocol) -> Bool {
        let activeView = setDocument.activeView
        let viewRelationValueIsLocked = activeView.type == .gallery ||
            activeView.type == .list ||
            (FeatureFlags.setKanbanView && activeView.type == .kanban)

        return !viewRelationValueIsLocked && setDocument.document.permissions.canEditRelationValues
    }
}
