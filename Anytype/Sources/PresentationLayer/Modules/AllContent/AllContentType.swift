import Services
import AnytypeCore

enum AllContentType: String, CaseIterable {
    case pages
    case lists
    case media
    case bookmarks
    case files
    
    var title: String {
        switch self {
        case .pages:
            Loc.pages
        case .lists:
            Loc.lists
        case .files:
            Loc.files
        case .media:
            Loc.media
        case .bookmarks:
            Loc.bookmarks
        }
    }
    
    var supportedLayouts: [DetailsLayout] {
        switch self {
        case .pages:
            DetailsLayout.editorLayouts
        case .lists:
            DetailsLayout.listLayouts
        case .files:
            DetailsLayout.fileLayouts
        case .media:
            DetailsLayout.mediaLayouts
        case .bookmarks:
            [.bookmark]
        }
    }
    
    var analyticsValue: String {
        switch self {
        case .pages:
            "Pages"
        case .lists:
            "Lists"
        case .files:
            "Files"
        case .media:
            "Media"
        case .bookmarks:
            "Bookmarks"
        }
    }
}
