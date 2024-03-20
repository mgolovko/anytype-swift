import Foundation
import Combine
import Services
import SwiftUI

@MainActor
final class SpacesManagerViewModel: ObservableObject {
    
    private let spacesSubscriptionService: SpaceManagerSpacesSubscriptionServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let participantsSubscriptionByAccountService: ParticipantsSubscriptionByAccountServiceProtocol
    
    private var spaces: [SpaceView] = []
    private var participants: [Participant] = []
    
    @Published var rows: [SpacesManagerRowViewModel] = []
    
    init(
        spacesSubscriptionService: SpaceManagerSpacesSubscriptionServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        participantsSubscriptionByAccountService: ParticipantsSubscriptionByAccountServiceProtocol
    ) {
        self.spacesSubscriptionService = spacesSubscriptionService
        self.workspaceService = workspaceService
        self.participantsSubscriptionByAccountService = participantsSubscriptionByAccountService
    }
    
    func onAppear() async {
        await participantsSubscriptionByAccountService.startSubscription { [weak self] items in
            self?.participants = items
            self?.updateRows()
        }
    }
    
    func startWorkspacesTask() async {
        await spacesSubscriptionService.startSubscription { [weak self] spaces in
            guard let self else { return }
            withAnimation(self.spaces.isEmpty ? nil : .default) {
                self.spaces = spaces
                self.updateRows()
            }
        }
    }
    
    func onDelete(row: SpacesManagerRowViewModel) async throws {
        try await workspaceService.deleteSpace(spaceId: row.spaceView.targetSpaceId)
    }
        
    func onCancelRequest(row: SpacesManagerRowViewModel) async throws {
        try await workspaceService.joinCancel(spaceId: row.spaceView.targetSpaceId)
    }
    
    func onArchive(row: SpacesManagerRowViewModel) async throws {
        // TODO: Implement it
    }
    
    // MARK: - Private
    
    private func updateRows() {
        rows = spaces.map { spaceView in
            let participant = participants.first { $0.spaceId == spaceView.targetSpaceId }
            return SpacesManagerRowViewModel(spaceView: spaceView, participant: participant)
        }
    }
}