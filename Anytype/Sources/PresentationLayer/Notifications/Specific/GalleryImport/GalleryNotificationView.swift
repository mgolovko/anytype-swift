import Foundation
import SwiftUI

struct GalleryNotificationView: View {
    
    @StateObject private var model: GalleryNotificationViewModel
    @Environment(\.notificationDismiss) private var dismiss
    
    init(notification: NotificationGalleryImport, homeSceneId: String) {
        _model = StateObject(wrappedValue: GalleryNotificationViewModel(notification: notification, homeSceneId: homeSceneId))
    }
    
    var body: some View {
        TopNotificationView(title: model.title, buttons: [
            TopNotificationButton(title: Loc.Gallery.Notification.button, action: {
                try await model.onTapSpace()
            })
        ])
        .onChange(of: model.dismiss) { _ in dismiss() }
    }
}
