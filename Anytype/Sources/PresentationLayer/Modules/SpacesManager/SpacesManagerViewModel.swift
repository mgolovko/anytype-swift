import Foundation
import Combine
import Services
import SwiftUI

@MainActor
final class SpacesManagerViewModel: ObservableObject {
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: ParticipantSpacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    @Published var participantSpaces: [ParticipantSpaceView] = []
    @Published var spaceForCancelRequestAlert: SpaceView?
        
    func startWorkspacesTask() async {
        for await participantSpaces in participantSpacesStorage.participantSpacesPublisher.values {
            withAnimation(self.participantSpaces.isEmpty ? nil : .default) {
                self.participantSpaces = participantSpaces
            }
        }
    }
    
    func onDelete(row: ParticipantSpaceView) async throws {
        try await workspaceService.deleteSpace(spaceId: row.spaceView.targetSpaceId)
    }
    
    func onLeave(row: ParticipantSpaceView) async throws {
        try await workspaceService.deleteSpace(spaceId: row.spaceView.targetSpaceId)
    }
        
    func onCancelRequest(row: ParticipantSpaceView) async throws {
        spaceForCancelRequestAlert = row.spaceView
    }
    
    func onArchive(row: ParticipantSpaceView) async throws {
        // TODO: Implement it
    }
}
