import BlocksModels
import Combine
import AnytypeCore

enum SubscriptionUpdate {
    case initialData([ObjectDetails])
    case update(ObjectDetails)
    case remove(BlockId)
    case add(ObjectDetails, after: BlockId?)
    case move(from: BlockId, after: BlockId?)
}
typealias SubscriptionCallback = (SubscriptionId, SubscriptionUpdate) -> ()


final class SubscriptionsStorage: ObservableObject {
    private var subscription: AnyCancellable?
    private let service: SubscriptionServiceProtocol = SubscriptionService()
    private let detailsStorage = ObjectDetailsStorage.shared
    
    private var turnedOnSubs = [SubscriptionId: SubscriptionCallback]()
    
    init() {
        setup()
    }
    
    deinit {
        stopAllSubscriptions()
    }
    
    func stopAllSubscriptions() {
        turnedOnSubs.keys.forEach { subId in
            _ = service.toggleSubscription(id: subId, false)
            turnedOnSubs[subId] = nil
        }
    }
    
    func toggleSubscriptions(ids: [SubscriptionId], turnOn: Bool, update: @escaping SubscriptionCallback) {
        ids.forEach { toggleSubscription(id: $0, turnOn: turnOn, update: update) }
    }
    
    func toggleSubscription(id: SubscriptionId, turnOn: Bool, update: @escaping SubscriptionCallback) {
        guard validateSubscription(id: id, turnOn: turnOn) else { return }
        
        turnedOnSubs[id] = update
        
        let details = service.toggleSubscription(id: id, turnOn) ?? []
        details.forEach { detailsStorage.add(details: $0) }
        
        update(id, .initialData(details))
    }
    
    private func validateSubscription(id: SubscriptionId, turnOn: Bool) -> Bool {
        if turnOn {
            guard turnedOnSubs[id].isNil else {
                anytypeAssertionFailure("Subscription: \(id) turned on second time", domain: .subscriptionStorage)
                return false
            }
        } else {
            guard turnedOnSubs[id].isNotNil else {
                anytypeAssertionFailure("Tryed to turn off not active subscription: \(id)", domain: .subscriptionStorage)
                return false
            }
        }
        
        return true
    }
 
    // MARK: - Private
    private let dependencySubscriptionSuffix = "/dep"
    
    private var objectIds: [String] {
        SubscriptionId.allCases.map { $0.rawValue } + [""]
    }
    
    private func setup() {
        subscription = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
            .compactMap { $0.object as? EventsBunch }
            .filter { [weak self] event in
                guard let self = self else { return false }
                guard event.objectId.isNotEmpty else { return true } // Empty object id in generic subscription
                
                guard let subscription = SubscriptionId(rawValue: event.objectId) else {
                    return false
                }
                
                return self.turnedOnSubs.keys.contains(subscription)
            }
            .sink { [weak self] events in
                self?.handle(events: events)
            }
    }
    
    private func handle(events: EventsBunch) {
        anytypeAssert(events.localEvents.isEmpty, "Local events with emplty objectId: \(events)", domain: .subscriptionStorage)
        
        for event in events.middlewareEvents {
            switch event.value {
            case .objectDetailsAmend(let data):
                let currentDetails = detailsStorage.get(id: data.id) ?? ObjectDetails.empty(id: data.id)
                
                let updatedDetails = currentDetails.updated(by: data.details.asDetailsDictionary)
                detailsStorage.add(details: updatedDetails)
                
                update(details: updatedDetails, rawSubIds: data.subIds)
            case .subscriptionPosition(let position):
                guard let subId = SubscriptionId(rawValue: events.objectId) else {
                    anytypeAssertionFailure("Unsupported object id \(events.objectId) in subscriptionPosition", domain: .subscriptionStorage)
                    break
                }
                
                guard let action = turnedOnSubs[subId] else { return }
                action(subId, .move(from: position.id, after: position.afterID.isNotEmpty ? position.afterID : nil))
            case .subscriptionAdd(let data):
                guard let subId = SubscriptionId(rawValue: events.objectId) else {
                    anytypeAssertionFailure("Unsupported object id \(events.objectId) in subscriptionRemove", domain: .subscriptionStorage)
                    break
                }
                
                guard let details = detailsStorage.get(id: data.id) else {
                    anytypeAssertionFailure("No details found for id \(data.id)", domain: .subscriptionStorage)
                    return
                }
                
                guard let action = turnedOnSubs[subId] else { return }
                action(subId, .add(details, after: data.afterID.isNotEmpty ? data.afterID : nil))
            case .subscriptionRemove(let remove):
                guard let subId = SubscriptionId(rawValue: events.objectId) else {
                    anytypeAssertionFailure("Unsupported object id \(events.objectId) in subscriptionRemove", domain: .subscriptionStorage)
                    break
                }
                
                guard let action = turnedOnSubs[subId] else { return }
                action(subId, .remove(remove.id))
            case .objectRemove:
                break // unsupported (Not supported in middleware converter also)
            case .subscriptionCounters:
                break // unsupported for now. Used for pagination
            case .accountConfigUpdate:
                break
            default:
                anytypeAssertionFailure("Unupported event \(event)", domain: .subscriptionStorage)
            }
        }
    }
    
    private func update(details: ObjectDetails, rawSubIds: [String]) {
        let ids: [SubscriptionId] = rawSubIds.compactMap { rawId in
            guard let id = SubscriptionId(rawValue: rawId) else {
                if !rawId.hasSuffix(dependencySubscriptionSuffix) {
                    anytypeAssertionFailure("Unrecognized subscription: \(rawId)", domain: .subscriptionStorage)
                }
                return nil
            }
            
            return id
        }
        
        for id in ids {
            guard let action = turnedOnSubs[id] else { continue }
            action(id, .update(details))
        }
    }
}
