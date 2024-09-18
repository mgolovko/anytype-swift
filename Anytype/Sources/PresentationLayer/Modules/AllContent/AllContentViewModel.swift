import Foundation
import Services

@MainActor
protocol AllContentModuleOutput: AnyObject {
    func onObjectSelected(screenData: EditorScreenData)
}

@MainActor
final class AllContentViewModel: ObservableObject {

    @Published var rows: [WidgetObjectListRowModel] = []
    @Published var state = AllContentState()
    @Published var searchText = ""
    
    @Injected(\.allContentSubscriptionService)
    private var allContentSubscriptionService: any AllContentSubscriptionServiceProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    private let spaceId: String
    private weak var output: (any AllContentModuleOutput)?
    
    init(spaceId: String, output: (any AllContentModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    func restartSubscription() async {
        await allContentSubscriptionService.startSubscription(
            spaceId: spaceId, 
            sorts: [state.sort.asDataviewSort()],
            supportedLayouts: state.type.supportedLayouts, 
            onlyUnlinked: state.mode == .unlinked,
            limitedObjectsIds: state.limitedObjectsIds
        ) { [weak self] details in
            self?.updateRows(with: details)
        }
    }
    
    func search() async {
        do {
            guard searchText.isNotEmpty else {
                state.limitedObjectsIds = nil
                return
            }
            
            try await Task.sleep(seconds: 0.3)
            
            state.limitedObjectsIds = try await searchService.searchAll(text: searchText, spaceId: spaceId).map { $0.id }
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            state.limitedObjectsIds = nil
        }
    }
    
    func onModeChanged(_ mode: AllContentMode) {
        state.mode = mode
    }
    
    func onTypeChanged(_ type: AllContentType) {
        state.type = type
    }
    
    func onSortChanged(_ sortRelation: AllContentSort.Relation) {
        if state.sort.relation == sortRelation {
            let type: DataviewSort.TypeEnum = state.sort.type == .asc ? .desc : .asc
            state.sort = AllContentSort(relation: sortRelation, type: type)
        } else {
            state.sort = AllContentSort(relation: sortRelation)
        }
    }
    
    func onDisappear() {
        stopSubscription()
    }
    
    private func stopSubscription() {
        Task {
            await allContentSubscriptionService.stopSubscription()
        }
    }
    
    private func updateRows(with details: [ObjectDetails]) {
        rows = details.map { details in
            WidgetObjectListRowModel(
                objectId: details.id,
                icon: details.objectIconImage,
                title: details.title,
                description: details.subtitle,
                subtitle: details.objectType.name,
                isChecked: false,
                menu: [],
                onTap: { [weak self] in
                    self?.output?.onObjectSelected(screenData: details.editorScreenData())
                },
                onCheckboxTap: nil
            )
        }
    }
}