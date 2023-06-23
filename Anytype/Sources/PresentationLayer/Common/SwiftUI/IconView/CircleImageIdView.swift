import SwiftUI
import AnytypeCore

struct CircleImageIdView: View {
    
    let imageId: String
    @State private var url: URL?
    @State private var size: CGSize = .zero
    
    var body: some View {
            AsyncImage(url: url, scale: UIScreen.main.scale) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                // TODO: Handle error. Add placeholder.
            }
            .mask(Circle())
            .readSize { size in
                let imageMetadata = ImageMetadata(id: imageId, width: .width(size.width))
                guard let url = imageMetadata.contentUrl else {
                    anytypeAssertionFailure("Url is nil")
                    return
                }
                self.url = url
                self.size = size
            }
            .frame(idealWidth: 30, idealHeight: 30) // Default frame
    }
}
