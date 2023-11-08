import Services

protocol SetObjectCreationCoordinatorProtocol {
    func startCreateObject(setDocument: SetDocumentProtocol, setting: ObjectCreationSetting?)
}

final class SetObjectCreationCoordinator: SetObjectCreationCoordinatorProtocol {
    
    private let navigationContext: NavigationContextProtocol
//    private let editorPageCoordinator: EditorPageCoordinatorProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let objectCreationHelper: SetObjectCreationHelperProtocol
    private let createObjectModuleAssembly: CreateObjectModuleAssemblyProtocol
    
    init(
        navigationContext: NavigationContextProtocol,
//        editorPageCoordinator: EditorPageCoordinatorProtocol,
        toastPresenter: ToastPresenterProtocol,
        objectCreationHelper: SetObjectCreationHelperProtocol,
        createObjectModuleAssembly: CreateObjectModuleAssemblyProtocol
    ) {
        self.navigationContext = navigationContext
//        self.editorPageCoordinator = editorPageCoordinator
        self.toastPresenter = toastPresenter
        self.objectCreationHelper = objectCreationHelper
        self.createObjectModuleAssembly = createObjectModuleAssembly
    }
    
    func startCreateObject(setDocument: SetDocumentProtocol, setting: ObjectCreationSetting?) {
        objectCreationHelper.createObject(for: setDocument, setting: setting) { [weak self] details in
            self?.handleCreatedObjectIfNeeded(details, setDocument: setDocument)
        }
    }
    
    private func handleCreatedObjectIfNeeded(_ details: ObjectDetails?, setDocument: SetDocumentProtocol) {
        if let details {
            showCreateObject(details: details)
            AnytypeAnalytics.instance().logCreateObject(
                objectType: details.analyticsType,
                route: setDocument.isCollection() ? .collection : .set
            )
        } else {
            showCreateBookmarkObject(setDocument: setDocument)
        }
    }
    
    private func showCreateObject(details: ObjectDetails) {
        let moduleViewController = createObjectModuleAssembly.makeCreateObject(objectId: details.id) { [weak self] in
            self?.navigationContext.dismissTopPresented()
            self?.showPage(data: details.editorScreenData())
        } closeAction: { [weak self] in
            self?.navigationContext.dismissTopPresented()
        }
        
        navigationContext.present(moduleViewController)
    }
    
    private func showCreateBookmarkObject(setDocument: SetDocumentProtocol) {
        let moduleViewController = createObjectModuleAssembly.makeCreateBookmark(
            spaceId: setDocument.spaceId,
            collectionId: setDocument.isCollection() ? setDocument.objectId : nil,
            closeAction: { [weak self] details in
                self?.navigationContext.dismissTopPresented(animated: true) {
                    guard details.isNil else { return }
                    self?.toastPresenter.showFailureAlert(message: Loc.Set.Bookmark.Error.message)
                }
            }
        )
        
        navigationContext.present(moduleViewController)
    }
    
    private func showPage(data: EditorScreenData) {
//        editorPageCoordinator.startFlow(data: data, replaceCurrentPage: false)
    }
}

extension SetObjectCreationCoordinatorProtocol {
    func startCreateObject(setDocument: SetDocumentProtocol) {
        startCreateObject(setDocument: setDocument, setting: nil)
    }
}
