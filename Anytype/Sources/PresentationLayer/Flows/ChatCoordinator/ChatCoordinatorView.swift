import SwiftUI

struct ChatCoordinatorView: View {
    
    @StateObject private var model: ChatCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: EditorChatObject) {
        self._model = StateObject(wrappedValue: ChatCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        chatView
            .onAppear {
                model.pageNavigation = pageNavigation
            }
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
            .sheet(item: $model.linkToObjectData) {
                LinkToObjectSearchView(data: $0, showEditorScreen: { _ in })
            }
            .photosPicker(isPresented: $model.showPhotosPicker, selection: $model.photosItems)
            .fileImporter(
                isPresented: $model.showFilesPicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: true
            ) { result in
                model.fileImporterFinished(result: result)
            }
            .onChange(of: model.photosItems) { _ in
                model.photosPickerFinished()
            }
    }
    
    @ViewBuilder
    private var chatView: some View {
        if let chatId = model.chatId {
            ChatView(objectId: model.objectId, spaceId: model.spaceId, chatId: chatId, output: model)
        } else {
            DotsView()
                .frame(width: 100, height: 15)
                .homeBottomPanelHidden(true)
        }
    }
}

#Preview {
    ChatCoordinatorView(data: EditorChatObject(objectId: "", spaceId: ""))
}
