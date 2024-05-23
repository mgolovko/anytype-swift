import Foundation
import SwiftUI

private struct URLViewModifier: ViewModifier {
    @Environment(\.openURL) private var openURL
    @Binding var url: URL?
    
    @State private var safariUrl: URL?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: url) { currentUrl in
                guard let currentUrl else { return }
                let fixedUrl = currentUrl.urlByAddingHttpIfSchemeIsEmpty()
                if fixedUrl.containsHttpProtocol {
                    safariUrl = fixedUrl
                } else {
                    openURL(currentUrl)
                }
                // If user tap again url should be changed for call onChange. Reset after open it.
                url = nil
            }
            .safariSheet(url: $safariUrl)
    }
}


extension View {
    func openUrl(url: Binding<URL?>) -> some View {
        modifier(URLViewModifier(url: url))
    }
}