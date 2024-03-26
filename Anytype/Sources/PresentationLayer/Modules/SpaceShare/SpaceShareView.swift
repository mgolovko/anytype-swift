import Foundation
import SwiftUI

struct SpaceShareView: View {
    
    @StateObject var model: SpaceShareViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceShare.title) {
                rightNavigationButton
            }
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        SectionHeaderView(title: Loc.SpaceShare.members)
                        ForEach(model.rows) { participant in
                            SpaceShareParticipantView(participant: participant)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .safeAreaInset(edge: .bottom) {
                    inviteView
                }
            }
        }
        .anytypeShareView(item: $model.shareInviteLink)
        .snackbar(toastBarData: $model.toastBarData)
        .anytypeSheet(item: $model.requestAlertModel) { model in
            SpaceRequestAlert(data: model)
        }
        .anytypeSheet(item: $model.changeAccessAlertModel) { model in
            SpaceChangeAccessView(model: model)
        }
        .anytypeSheet(item: $model.removeParticipantAlertModel) { model in
            SpaceParticipantRemoveView(model: model)
        }
        .anytypeSheet(isPresented: $model.showDeleteLinkAlert) {
            DeleteSharingLinkAlert(spaceId: model.accountSpaceId) {
                model.onDeleteLinkCompleted()
            }
        }
        .anytypeSheet(isPresented: $model.showStopSharingAlert) {
            StopSharingAlert(spaceId: model.accountSpaceId) {
                model.onStopSharingCompleted()
            }
        }
    }
    
    private var inviteView: some View {
        InviteLinkView(invite: model.inviteLink) {
            model.onShareInvite()
        } onCopyLink: {
            model.onCopyLink()
        } onDeleteSharingLink: {
            model.onDeleteSharingLink()
        } onGenerateInvite: {
            try await model.onGenerateInvite()
        }
    }
    
    private var rightNavigationButton: some View {
        Menu {
            Button(Loc.SpaceShare.StopSharing.action, role: .destructive) {
                model.onStopSharing()
            }
        } label: {
            IconView(icon: .asset(.X24.more))
                .frame(width: 24, height: 24)
        }
    }
}
