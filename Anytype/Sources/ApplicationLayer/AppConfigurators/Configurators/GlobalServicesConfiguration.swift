import Foundation
import AnytypeCore

final class GlobalServicesConfiguration: AppConfiguratorProtocol {
    
    @Injected(\.middlewareEventsListener)
    private var eventListener: any MiddlewareEventsListenerProtocol
    @Injected(\.accountEventHandler)
    private var accountEventHandler: any AccountEventHandlerProtocol
    @Injected(\.fileErrorEventHandler)
    private var fileErrorEventHandler: any FileErrorEventHandlerProtocol
    @Injected(\.deviceSceneStateListener)
    private var deviceSceneStateListener: any DeviceSceneStateListenerProtocol
    @Injected(\.appVersionUpdateService)
    private var appVersionUpdateService: any AppVersionUpdateServiceProtocol
    
    func configure() {
        // Global listeners
        eventListener.startListening()
        accountEventHandler.startSubscription()
        fileErrorEventHandler.startSubscription()
        deviceSceneStateListener.start()
        appVersionUpdateService.prepareData()
    }
}
