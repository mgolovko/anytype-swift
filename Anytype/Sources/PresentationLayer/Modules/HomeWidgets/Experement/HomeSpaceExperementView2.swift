import Foundation
import SwiftUI

struct HomeSpaceExperementView2: View {
    
    @StateObject private var model: HomeSpaceExperementViewModel2
    @Binding private var state: HomeWidgetsExperementalState
    
    init(spaceId: String, state: Binding<HomeWidgetsExperementalState>) {
        self._model = StateObject(wrappedValue: HomeSpaceExperementViewModel2(spaceId: spaceId))
        self._state = state
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            Spacer.fixedWidth(31)
            
            IconView(icon: model.icon)
                .frame(width: 48, height: 48)
                .padding(.vertical, 31)
            
            Spacer.fixedWidth(26)
            
            Text(verbatim: model.name)
                .anytypeStyle(.previewTitle2Medium)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(2)
            
            Spacer.fixedWidth(10)
            
            Spacer()
            
            VStack(spacing: 10) {
                Image(asset: .X32.sendMessage)
                    .foregroundStyle(state == .chat ? Color.Text.primary : Color.Experement.widgetIconNewColor2)
                    .frame(width: 36, height: 36)
//                    .background(Color.Widget.card.opacity(state == .chat ? 0.5 : 1))
//                    .cornerRadius(16, style: .continuous)
                    .onTapGesture {
                        withAnimation {
                            state = .chat
                        }
                    }
                    
                Image(asset: .Experement.inbox)
                    .foregroundStyle(Color.Experement.widgetIconNewColor2)
                    .frame(width: 36, height: 36)
//                    .background(Color.Widget.card)
//                    .cornerRadius(16, style: .continuous)
                
            }
            Spacer.fixedWidth(10)
            VStack(spacing: 10) {
                Image(asset: .Experement.widgets)
                    .foregroundStyle(state == .widgets ? Color.Text.primary : Color.Experement.widgetIconNewColor2)
                    .frame(width: 36, height: 36)
//                    .background(Color.Widget.card.opacity(state == .widgets ? 0.5 : 1))
//                    .cornerRadius(16, style: .continuous)
                    .onTapGesture {
                        withAnimation {
                            state = .widgets
                        }
                    }
                Image(asset: .Experement.objects)
                    .foregroundStyle(Color.Experement.widgetIconNewColor2)
                    .frame(width: 36, height: 36)
//                    .background(Color.Widget.card)
//                    .cornerRadius(16, style: .continuous)
                
            }
            
            Spacer.fixedWidth(26)
        }
            
//            VStack(alignment: .leading, spacing: 12) {
//                HStack {
//                    IconView(icon: model.icon)
//                        .frame(width: 48, height: 48)
//                    Spacer()
//                }
//                
//                Text(verbatim: model.name)
//                    .anytypeStyle(.previewTitle2Medium)
//                    .foregroundStyle(Color.Text.primary)
//                    .lineLimit(1)
//            }
//            .padding(16)
//            .frame(height: 112)
//            .background(Color.Widget.card)
//            .cornerRadius(16, style: .continuous)
//        }
        .task {
            await model.startSubscription()
        }
    }
}

@MainActor
final class HomeSpaceExperementViewModel2: ObservableObject {
    
    private let spaceId: String
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
    @Published var name: String = ""
    @Published var icon: Icon? = nil
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func startSubscription() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
            name = spaceView.name
            icon = spaceView.objectIconImage
        }
    }
}
