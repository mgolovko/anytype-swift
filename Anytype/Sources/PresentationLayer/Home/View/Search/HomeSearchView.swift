import SwiftUI

struct HomeSearchView: View {
    @EnvironmentObject var viewModel: HomeViewModel
        
    var body: some View {
        let searchViewModel = ObjectSearchViewModel(
            searchService: ServiceLocator.shared.searchService()
        ) { [weak viewModel] data in
            viewModel?.showPage(id: data.blockId, viewType: data.viewType)
        }
        return SearchView(title: nil, context: .general, viewModel: searchViewModel)
    }
}
