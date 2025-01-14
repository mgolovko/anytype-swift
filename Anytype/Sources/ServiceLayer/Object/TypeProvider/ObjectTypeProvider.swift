import AnytypeCore
import Services
import ProtobufMessages
import Combine

enum ObjectTypeError: Error {
    case objectTypeNotFound
}

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
    
    private enum Constants {
        static let subscriptionIdPrefix = "SubscriptionId.ObjectType-"
    }
    
    // MARK: - Shared
    
    static let shared: any ObjectTypeProviderProtocol = ObjectTypeProvider()
    
    // MARK: - DI
    
    @Injected(\.objectTypeSubscriptionDataBuilder)
    private var subscriptionBuilder: any MultispaceSubscriptionDataBuilderProtocol
    private var userDefaults: any UserDefaultsStorageProtocol
    
    private lazy var multispaceSubscriptionHelper = MultispaceSubscriptionHelper<ObjectType>(
        subIdPrefix: Constants.subscriptionIdPrefix,
        subscriptionBuilder: subscriptionBuilder
    )
    
    // MARK: - Private variables
        
    private var searchTypesById = SynchronizedDictionary<String, ObjectType>()
    
    @Published private var defaultObjectTypes: [String: String] {
        didSet {
            userDefaults.defaultObjectTypes = defaultObjectTypes
        }
    }
    @Published var sync: () = ()
    var syncPublisher: AnyPublisher<Void, Never> { $sync.eraseToAnyPublisher() }

    private init() {
        let userDefaults = Container.shared.userDefaultsStorage()
        self.userDefaults = userDefaults
        defaultObjectTypes = userDefaults.defaultObjectTypes
    }
    
    // MARK: - ObjectTypeProviderProtocol
    
    func defaultObjectTypePublisher(spaceId: String) -> AnyPublisher<ObjectType, Never> {
        return $defaultObjectTypes.combineLatest(syncPublisher)
            .compactMap { [weak self] storage, _ in try? self?.defaultObjectType(storage: storage, spaceId: spaceId) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func defaultObjectType(spaceId: String) throws -> ObjectType {
       return try defaultObjectType(storage: defaultObjectTypes, spaceId: spaceId)
    }
    
    func setDefaultObjectType(type: ObjectType, spaceId: String, route: AnalyticsDefaultObjectTypeChangeRoute) {
        defaultObjectTypes[spaceId] = type.id
        AnytypeAnalytics.instance().logDefaultObjectTypeChange(type.analyticsType, route: route)
    }

    func objectType(id: String) throws -> ObjectType {
        guard let result = searchTypesById[id] else {
            throw ObjectTypeError.objectTypeNotFound
        }
        return result
    }
    
    func objectType(recommendedLayout: DetailsLayout, spaceId: String) throws -> ObjectType {
        let result = objectTypes(spaceId: spaceId).filter { $0.recommendedLayout == recommendedLayout }
        if result.count > 1 {
            anytypeAssertionFailure("Multiple types contains recommendedLayout", info: ["recommendedLayout": "\(recommendedLayout.rawValue)"])
        }
        guard let first = result.first else {
            anytypeAssertionFailure("Object type not found by recommendedLayout", info: ["recommendedLayout": "\(recommendedLayout.rawValue)"])
            throw ObjectTypeError.objectTypeNotFound
        }
        return first
    }
    
    func objectType(uniqueKey: ObjectTypeUniqueKey, spaceId: String) throws -> ObjectType {
        let result = objectTypes(spaceId: spaceId).filter { $0.uniqueKey == uniqueKey }
        if result.count > 1 {
            anytypeAssertionFailure("Multiple types contains uniqueKey", info: ["uniqueKey": "\(uniqueKey)"])
        }
        
        guard let first = result.first else {
            anytypeAssertionFailure("Object type not found by uniqueKey", info: ["uniqueKey": "\(uniqueKey)"])
            throw ObjectTypeError.objectTypeNotFound
        }
        return first
    }
    
    func objectTypes(spaceId: String) -> [ObjectType] {
        return multispaceSubscriptionHelper.data[spaceId] ?? []
    }
    
    func deletedObjectType(id: String) -> ObjectType {
        return ObjectType(
            id: id,
            name: Loc.ObjectType.deletedName,
            iconEmoji: nil,
            description: "",
            hidden: false,
            readonly: true,
            isArchived: false,
            isDeleted: true,
            sourceObject: "",
            spaceId: "",
            uniqueKey: .empty,
            defaultTemplateId: "",
            canCreateObjectOfThisType: false,
            recommendedRelations: [],
            recommendedLayout: nil
        )
    }
    
    func startSubscription() async {
        await multispaceSubscriptionHelper.startSubscription { [weak self] in
            self?.updateAllCache()
            self?.sync = ()
        }
    }
    
    func stopSubscription() async {
        await multispaceSubscriptionHelper.stopSubscription()
        updateAllCache()
    }
    
    // MARK: - Private func
    
    private func updateAllCache() {
        updateSearchCache()
    }
    
    private func updateSearchCache() {
        searchTypesById.removeAll()
        let types = multispaceSubscriptionHelper.data.values.flatMap { $0 }
        types.forEach {
            if searchTypesById[$0.id] != nil {
                anytypeAssertionFailure("Dublicate object type found", info: ["id": $0.id])
            }
            searchTypesById[$0.id] = $0
        }
    }
    
    private func findPageType(spaceId: String) -> ObjectType? {
        return objectTypes(spaceId: spaceId).first { $0.uniqueKey == .page }
    }
    
    private func defaultObjectType(storage: [String: String], spaceId: String) throws -> ObjectType {
        let typeId = storage[spaceId]
        guard let type = objectTypes(spaceId: spaceId).first(where: { $0.id == typeId }) ?? findPageType(spaceId: spaceId) else {
            throw ObjectTypeError.objectTypeNotFound
        }
        return type
    }
}
