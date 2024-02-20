import ProtobufMessages
import Services
import Foundation

struct EventsBunch {
    let contextId: String
    let middlewareEvents: [Anytype_Event.Message]
    let localEvents: [LocalEvent]
    let dataSourceEvents: [LocalEvent]

    func send() async {
        await EventBunchSubscribtion.default.sendEvent(events: self)
    }
}

extension EventsBunch {

    init(contextId: String, middlewareEvents: [Anytype_Event.Message]) {
        self.contextId = contextId
        self.middlewareEvents = middlewareEvents
        self.localEvents = []
        self.dataSourceEvents = []
    }

    init(contextId: String, localEvents: [LocalEvent]) {
        self.contextId = contextId
        self.middlewareEvents = []
        self.localEvents = localEvents
        self.dataSourceEvents = []
    }

    init(event: Anytype_Event) {
        self.init(contextId: event.contextID, middlewareEvents: event.messages)
    }

    init(event: Anytype_ResponseEvent) {
        self.init(contextId: event.contextID, middlewareEvents: event.messages)
    }

    init(contextId: String, dataSourceUpdateEvents: [LocalEvent]) {
        self.init(
            contextId: contextId,
            middlewareEvents: [],
            localEvents: [],
            dataSourceEvents: dataSourceUpdateEvents
        )
    }
}
