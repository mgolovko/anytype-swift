import Foundation
import Services

struct ParticipantSpaceView {
    let spaceView: SpaceView
    let participant: Participant
}

extension ParticipantSpaceView: Identifiable {
    var id: String { spaceView.id }
}

extension ParticipantSpaceView {
    var canBeShared: Bool {
        spaceView.canBeShared(isOwner: participant.isOwner)
    }
}
