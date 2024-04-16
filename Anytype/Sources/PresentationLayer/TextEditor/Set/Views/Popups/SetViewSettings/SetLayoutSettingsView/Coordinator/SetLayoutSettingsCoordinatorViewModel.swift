import SwiftUI

@MainActor
protocol SetLayoutSettingsCoordinatorOutput: AnyObject {
    func onImagePreviewTap(completion: @escaping (String) -> Void)
    func onGroupByTap(completion: @escaping (String) -> Void)
}

@MainActor
final class SetLayoutSettingsCoordinatorViewModel: ObservableObject, SetLayoutSettingsCoordinatorOutput {
    @Published var imagePreviewData: SheetData?
    @Published var groupByData: SheetData?
    
    let setDocument: SetDocumentProtocol
    let viewId: String
    private let setViewSettingsImagePreviewModuleAssembly: SetViewSettingsImagePreviewModuleAssemblyProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        setViewSettingsImagePreviewModuleAssembly: SetViewSettingsImagePreviewModuleAssemblyProtocol
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.setViewSettingsImagePreviewModuleAssembly = setViewSettingsImagePreviewModuleAssembly
    }
    
    // MARK: - SetLayoutSettingsCoordinatorOutput
    
    func onImagePreviewTap(completion: @escaping (String) -> Void) {
        imagePreviewData = SheetData(completion: completion)
    }
    
    func imagePreview(data: SheetData) -> AnyView {
        setViewSettingsImagePreviewModuleAssembly.make(
            setDocument: setDocument,
            onSelect: data.completion
        )
    }
    
    func onGroupByTap(completion: @escaping (String) -> Void) {
        groupByData = SheetData(completion: completion)
    }
}

extension SetLayoutSettingsCoordinatorViewModel {
    struct SheetData: Identifiable {
        let id = UUID()
        let completion: (String) -> Void
    }
}

