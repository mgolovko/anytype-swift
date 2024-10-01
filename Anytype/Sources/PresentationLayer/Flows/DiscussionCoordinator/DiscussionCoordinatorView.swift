import SwiftUI

struct DiscussionCoordinatorView: View {
    
    @StateObject private var model: DiscussionCoordinatorViewModel
    
    init(data: EditorDiscussionObject) {
        self._model = StateObject(wrappedValue: DiscussionCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        chatView
            .task {
                await model.startHandleDetails()
            }
            .sheet(item: $model.objectToMessageSearchData) {
                BlockObjectSearchView(data: $0)
            }
            .sheet(item: $model.showEmojiData) {
                MessageReactionPickerView(data: $0)
            }
            .anytypeSheet(isPresented: $model.showSyncStatusInfo) {
                SyncStatusInfoView(spaceId: model.spaceId)
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
    }
    
    @ViewBuilder
    private var chatView: some View {
        if let chatId = model.chatId {
            DiscussionView(objectId: model.objectId, spaceId: model.spaceId, chatId: chatId, output: model)
        } else {
            Spacer()
        }
    }
}

#Preview {
    DiscussionCoordinatorView(data: EditorDiscussionObject(objectId: "", spaceId: ""))
}
