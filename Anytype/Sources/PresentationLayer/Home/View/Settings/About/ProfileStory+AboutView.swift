import Foundation
import Combine
import SwiftUI
import Amplitude


struct AboutView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        contentView
            .onAppear {
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.showAboutScreen)

                viewModel.viewLoaded()
            }
    }
    
    var contentView: some View {
        VStack(alignment: .center) {
            DragIndicator()
            AnytypeText("Anytype info", style: .title).padding()
            AnytypeText("Library version", style: .subheading).padding()
            AnytypeText(viewModel.libraryVersion, style: .subheading)
            Spacer()
        }
        .padding([.leading, .trailing])
    }
}

extension AboutView {
    class ViewModel: ObservableObject {
        private var configurationService = MiddlewareConfigurationService()
        private var subscription: AnyCancellable?
        @Published var libraryVersion: String = ""

        func viewLoaded() {
            subscription = configurationService.libraryVersionPublisher().receiveOnMain()
                .sinkWithDefaultCompletion("Obtain library version") { [weak self] version in
                    self?.libraryVersion = version.version
                }
        }
    }
}
