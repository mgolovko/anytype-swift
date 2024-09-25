import Foundation
import SwiftUI

struct HomeSpaceExperementView: View {
    
    @StateObject private var model: HomeSpaceExperementViewModel
    @Binding private var state: HomeWidgetsExperementalState
    
    init(spaceId: String, state: Binding<HomeWidgetsExperementalState>) {
        self._model = StateObject(wrappedValue: HomeSpaceExperementViewModel(spaceId: spaceId))
        self._state = state
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    IconView(icon: model.icon)
                        .frame(width: 48, height: 48)
                    Spacer()
                }
                
                Text(verbatim: model.name)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
            }
            .padding(16)
            .frame(height: 112)
            .background(Color.Widget.card)
            .cornerRadius(16, style: .continuous)
            
            VStack {
                Image(asset: .X32.sendMessage)
                    .foregroundStyle(Color.Experement.widgetIconNewColor)
                    .frame(width: 52, height: 52)
                    .background(Color.Widget.card.opacity(state == .chat ? 0.5 : 1))
                    .cornerRadius(16, style: .continuous)
                    .onTapGesture {
                        state = .chat
                    }
                    
                Image(asset: .Experement.inbox)
                    .foregroundStyle(Color.Experement.widgetIconColor)
                    .frame(width: 52, height: 52)
                    .background(Color.Widget.card)
                    .cornerRadius(16, style: .continuous)
                
            }
            VStack {
                Image(asset: .Experement.widgets)
                    .foregroundStyle(Color.Experement.widgetIconColor)
                    .frame(width: 52, height: 52)
                    .background(Color.Widget.card.opacity(state == .widgets ? 0.5 : 1))
                    .cornerRadius(16, style: .continuous)
                    .onTapGesture {
                        state = .widgets
                    }
                Image(asset: .Experement.objects)
                    .foregroundStyle(Color.Experement.widgetIconColor)
                    .frame(width: 52, height: 52)
                    .background(Color.Widget.card)
                    .cornerRadius(16, style: .continuous)
                
            }
        }
        .task {
            await model.startSubscription()
        }
    }
}

@MainActor
final class HomeSpaceExperementViewModel: ObservableObject {
    
    private let spaceId: String
    
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    
    @Published var name: String = ""
    @Published var icon: Icon? = nil
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func startSubscription() async {
        for await participant in await accountParticipantsStorage.participantPublisher(spaceId: spaceId).values {
            name = participant.title
            icon = participant.icon.map { Icon.object($0) }
        }
    }
}
