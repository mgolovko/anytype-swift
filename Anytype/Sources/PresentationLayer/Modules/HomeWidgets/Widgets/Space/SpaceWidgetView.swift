import Foundation
import SwiftUI

struct SpaceWidgetView: View {
    
    @StateObject private var model: SpaceWidgetViewModel
    
    init(spaceId: String, onSpaceSelected: @escaping () -> Void) {
        _model = StateObject(wrappedValue: SpaceWidgetViewModel(spaceId: spaceId, onSpaceSelected: onSpaceSelected))
    }
    
    var body: some View {
        HStack(spacing: 15) {
            IconView(icon: model.spaceIcon)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 1) {
                AnytypeText(model.spaceName, style: .previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
                if model.sharedSpace {
                    AnytypeText(model.spaceMembers, style: .relation3Regular)
                        .foregroundColor(.Text.secondary)
                } else {
                    AnytypeText(model.spaceAccessType, style: .relation3Regular)
                        .foregroundColor(.Text.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 68)
        .background(Color.Widget.card)
        .cornerRadius(16, style: .continuous)
        .onTapGesture {
            model.onTapWidget()
        }
        .task {
            await model.startSpaceTask()
        }
        .task {
            await model.startParticipantTask()
        }
    }
}
