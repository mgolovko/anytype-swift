import Foundation
import BlocksModels
import Combine
import SwiftUI

final class ObjectTypesSearchViewModel {
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    
    private var objects: [ObjectDetails] = []
    private let interactor: ObjectTypesSearchInteractor
    private let selectedObjectId: BlockId?
    private let onSelect: (_ ids: [String]) -> Void
    
    init(
        interactor: ObjectTypesSearchInteractor,
        selectedObjectId: BlockId? = nil,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) {
        self.interactor = interactor
        self.selectedObjectId = selectedObjectId
        self.onSelect = onSelect
    }
}

extension ObjectTypesSearchViewModel: NewInternalSearchViewModelProtocol {
    
    func search(text: String) {
        let objects = interactor.search(text: text)
        
        if objects.isEmpty {
            handleError(for: text)
        } else {
            handleSearchResults(objects)
        }
        
        self.objects = objects
    }
    
    func handleRowsSelection(ids: [String]) {}
    
    func handleConfirmSelection(ids: [String]) {
        onSelect(ids)
    }
}

private extension ObjectTypesSearchViewModel {
    
    func handleError(for text: String) {
        viewStateSubject.send(.error(.noObjectError(searchText: text)))
    }
    
    func handleSearchResults(_ objects: [ObjectDetails]) {
        viewStateSubject.send(
            .resultsList(
                .plain(rows: objects.asRowConfigurations(selectedId: selectedObjectId))
            )
        )
    }
    
}

private extension Array where Element == ObjectDetails {

    func asRowConfigurations(selectedId: BlockId?) -> [ListRowConfiguration] {
        sorted { lhs, rhs in
            lhs.id == selectedId && rhs.id != selectedId
        }.map { details in
            ListRowConfiguration(
                id: details.id,
                contentHash: details.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(details: details, isChecked: details.id == selectedId),
                    selectionIndicatorViewModel: nil
                ).eraseToAnyView()
            }
        }
    }
    
}

private extension SearchObjectRowView.Model {
    
    init(details: ObjectDetails, isChecked: Bool) {
        let title = details.title
        self.icon = {
            if details.layoutValue == .todo {
                return .todo(details.isDone)
            } else {
                return details.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
            }
        }()
        self.title = title
        self.subtitle = details.description
        self.style = .default
        self.isChecked = isChecked
    }
    
}
