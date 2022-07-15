import SwiftUI
import BlocksModels

final class SetFiltersSearchHeaderViewModel: ObservableObject {
    @Published var headerConfiguration: SetFiltersSearchHeaderConfiguration
    
    var onConditionChanged: ((DataviewFilter.Condition) -> Void)?
    
    private var filter: SetFilter
    private let router: EditorRouterProtocol
    
    init(
        filter: SetFilter,
        router: EditorRouterProtocol
    ) {
        self.filter = filter
        self.router = router
        self.headerConfiguration = Self.headerConfiguration(with: filter)
    }
    
    func conditionTapped() {
        showFilterConditions()
    }
    
    // MARK: - Private methods
    
    private static func headerConfiguration(with filter: SetFilter) -> SetFiltersSearchHeaderConfiguration {
        SetFiltersSearchHeaderConfiguration(
            id: filter.id,
            title: filter.metadata.name,
            condition: filter.conditionString ?? "",
            iconName: filter.metadata.format.iconName
        )
    }
    
    private func updateFilter(with condition: DataviewFilter.Condition) {
        filter = filter.updated(
            filter: filter.filter.updated(
                condition: condition
            )
        )
        headerConfiguration = Self.headerConfiguration(with: filter)
        onConditionChanged?(condition)
    }
    
    private func showFilterConditions() {
        let view = CheckPopupView(
            viewModel: SetFilterConditionsViewModel(
                filter: filter,
                onSelect: { [weak self] condition in
                    self?.updateFilter(with: condition)
                }
            )
        )
        router.presentSheet(
            AnytypePopup(
                contentView: view
            )
        )
    }
}