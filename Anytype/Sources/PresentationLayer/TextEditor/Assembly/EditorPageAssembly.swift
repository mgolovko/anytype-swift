import BlocksModels
import UIKit
import AnytypeCore
import SwiftUI

final class EditorAssembly {
    
    private let serviceLocator: ServiceLocator
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        serviceLocator: ServiceLocator,
        coordinatorsDI: CoordinatorsDIProtocol,
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.serviceLocator = serviceLocator
        self.coordinatorsDI = coordinatorsDI
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    func buildEditorController(
        browser: EditorBrowserController?,
        data: EditorScreenData,
        widgetListOutput: WidgetObjectListCommonModuleOutput? = nil
    ) -> UIViewController {
        buildEditorModule(browser: browser, data: data, widgetListOutput: widgetListOutput).vc
    }

    func buildEditorModule(
        browser: EditorBrowserController?,
        data: EditorScreenData,
        widgetListOutput: WidgetObjectListCommonModuleOutput? = nil
    ) -> (vc: UIViewController, router: EditorPageOpenRouterProtocol?) {
        switch data.type {
        case .page:
            return buildPageModule(browser: browser, data: data)
        case let .set(blockId, targetObjectID):
            return buildSetModule(
                browser: browser,
                data: data,
                blockId: blockId,
                targetObjectID: targetObjectID
            )
        case .favorites:
            return favoritesModule(output: widgetListOutput)
        case .recent:
            return recentModule(output: widgetListOutput)
        case .sets:
            return setsModule(output: widgetListOutput)
        }
    }
    
    // MARK: - Set
    private func buildSetModule(
        browser: EditorBrowserController?,
        data: EditorScreenData,
        blockId: BlockId?,
        targetObjectID: String?
    ) -> (EditorSetHostingController, EditorPageOpenRouterProtocol) {
        let document = BaseDocument(objectId: data.pageId)
        let setDocument = SetDocument(
            document: document,
            blockId: blockId,
            targetObjectID: targetObjectID,
            relationDetailsStorage: serviceLocator.relationDetailsStorage()
        )
        let dataviewService = DataviewService(
            objectId: data.pageId,
            blockId: blockId,
            prefilledFieldsBuilder: SetPrefilledFieldsBuilder()
        )
        let detailsService = serviceLocator.detailsService(objectId: data.pageId)
        
        let model = EditorSetViewModel(
            setDocument: setDocument,
            subscriptionService: serviceLocator.subscriptionService(),
            dataviewService: dataviewService,
            searchService: serviceLocator.searchService(),
            detailsService: detailsService,
            objectActionsService: serviceLocator.objectActionsService(),
            textService: serviceLocator.textService,
            groupsSubscriptionsHandler: serviceLocator.groupsSubscriptionsHandler(),
            setSubscriptionDataBuilder: SetSubscriptionDataBuilder(accountManager: serviceLocator.accountManager())
        )
        let controller = EditorSetHostingController(objectId: data.pageId, model: model)

        let router = EditorSetRouter(
            setDocument: setDocument,
            rootController: browser,
            viewController: controller,
            navigationContext: NavigationContext(rootViewController: browser ?? controller),
            createObjectModuleAssembly: modulesDI.createObject(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            editorPageCoordinator: coordinatorsDI.editorPage().make(browserController: browser),
            addNewRelationCoordinator: coordinatorsDI.addNewRelation().make(document: document),
            objectSettingCoordinator: coordinatorsDI.objectSettings().make(document: document, browserController: browser),
            relationValueCoordinator: coordinatorsDI.relationValue().make(),
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker(),
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker(),
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            alertHelper: AlertHelper(viewController: controller)
        )
        
        model.setup(router: router)
        
        return (controller, router)
    }
    
    // MARK: - Page
    
    private func buildPageModule(
        browser: EditorBrowserController?,
        data: EditorScreenData
    ) -> (EditorPageController, EditorPageOpenRouterProtocol) {
        let simpleTableMenuViewModel = SimpleTableMenuViewModel()
        let blocksOptionViewModel = SelectionOptionsViewModel(itemProvider: nil)

        let blocksSelectionOverlayView = buildBlocksSelectionOverlayView(
            simleTableMenuViewModel: simpleTableMenuViewModel,
            blockOptionsViewViewModel: blocksOptionViewModel
        )
        let bottomNavigationManager = EditorBottomNavigationManager(browser: browser)
        
        let controller = EditorPageController(
            blocksSelectionOverlayView: blocksSelectionOverlayView,
            bottomNavigationManager: bottomNavigationManager,
            browserViewInput: browser
        )
        let document = BaseDocument(objectId: data.pageId)
        let router = EditorRouter(
            rootController: browser,
            viewController: controller,
            navigationContext: NavigationContext(rootViewController: browser ?? controller),
            document: document,
            addNewRelationCoordinator: coordinatorsDI.addNewRelation().make(document: document),
            templatesCoordinator: coordinatorsDI.templates().make(viewController: controller),
            urlOpener: URLOpener(viewController: browser),
            relationValueCoordinator: coordinatorsDI.relationValue().make(),
            editorPageCoordinator: coordinatorsDI.editorPage().make(browserController: browser),
            linkToObjectCoordinator: coordinatorsDI.linkToObject().make(browserController: browser),
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker(),
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker(),
            objectSettingCoordinator: coordinatorsDI.objectSettings().make(document: document, browserController: browser),
            searchModuleAssembly: modulesDI.search(),
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            codeLanguageListModuleAssembly: modulesDI.codeLanguageList(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            textIconPickerModuleAssembly: modulesDI.textIconPicker(),
            alertHelper: AlertHelper(viewController: controller)
        )

        let viewModel = buildViewModel(
            browser: browser,
            controller: controller,
            scrollView: controller.collectionView,
            viewInput: controller,
            document: document,
            router: router,
            blocksOptionViewModel: blocksOptionViewModel,
            simpleTableMenuViewModel: simpleTableMenuViewModel,
            blocksSelectionOverlayViewModel: blocksSelectionOverlayView.viewModel,
            bottomNavigationManager: bottomNavigationManager,
            isOpenedForPreview: data.isOpenedForPreview
        )

        controller.viewModel = viewModel
        
        return (controller, router)
    }
    
    private func buildViewModel(
        browser: EditorBrowserController?,
        controller: UIViewController,
        scrollView: UIScrollView,
        viewInput: EditorPageViewInput,
        document: BaseDocumentProtocol,
        router: EditorRouter,
        blocksOptionViewModel: SelectionOptionsViewModel,
        simpleTableMenuViewModel: SimpleTableMenuViewModel,
        blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel,
        bottomNavigationManager: EditorBottomNavigationManagerProtocol,
        isOpenedForPreview: Bool
    ) -> EditorPageViewModel {
        let modelsHolder = EditorMainItemModelsHolder()
        let markupChanger = BlockMarkupChanger(infoContainer: document.infoContainer)
        let focusSubjectHolder = FocusSubjectsHolder()

        let cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
        let listService = serviceLocator.blockListService(documentId: document.objectId)
        let singleService = serviceLocator.blockActionsServiceSingle(contextId: document.objectId)
        let blockActionService = BlockActionService(
            documentId: document.objectId,
            listService: listService,
            singleService: singleService,
            objectActionService: serviceLocator.objectActionsService(),
            modelsHolder: modelsHolder,
            bookmarkService: serviceLocator.bookmarkService(),
            cursorManager: cursorManager
        )
        let keyboardHandler = KeyboardActionHandler(
            service: blockActionService,
            listService: listService,
            toggleStorage: ToggleStorage.shared,
            container: document.infoContainer,
            modelsHolder: modelsHolder
        )

        let blockTableService = BlockTableService()
        let actionHandler = BlockActionHandler(
            document: document,
            markupChanger: markupChanger,
            service: blockActionService,
            listService: listService,
            keyboardHandler: keyboardHandler,
            blockTableService: blockTableService
        )

        let pasteboardMiddlewareService = PasteboardMiddleService(document: document)
        let pasteboardHelper = PasteboardHelper()
        let pasteboardService = PasteboardService(document: document,
                                                  pasteboardHelper: pasteboardHelper,
                                                  pasteboardMiddlewareService: pasteboardMiddlewareService)

        let blockActionsServiceSingle = serviceLocator
            .blockActionsServiceSingle(contextId: document.objectId)

        let blocksStateManager = EditorPageBlocksStateManager(
            document: document,
            modelsHolder: modelsHolder,
            blocksSelectionOverlayViewModel: blocksSelectionOverlayViewModel,
            blockActionsServiceSingle: blockActionsServiceSingle,
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            actionHandler: actionHandler,
            pasteboardService: pasteboardService,
            router: router,
            initialEditingState: isOpenedForPreview ? .locked : .editing,
            viewInput: viewInput,
            bottomNavigationManager: bottomNavigationManager
        )
        
        let accessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: actionHandler,
            router: router,
            pasteboardService: pasteboardService,
            document: document,
            onShowStyleMenu: blocksStateManager.didSelectStyleSelection(info:),
            onBlockSelection: actionHandler.selectBlock(info:),
            pageService: serviceLocator.pageService(),
            linkToObjectCoordinator: coordinatorsDI.linkToObject().make(browserController: browser)
        )
        
        let markdownListener = MarkdownListenerImpl(
            internalListeners: [
                BeginingOfTextMarkdownListener(),
                InlineMarkdownListener()
            ]
        )
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryState: accessoryState,
            cursorManager: cursorManager
        )

        let headerModel = ObjectHeaderViewModel(
            document: document,
            router: router,
            isOpenedForPreview: isOpenedForPreview
        )

        let responderScrollViewHelper = ResponderScrollViewHelper(scrollView: scrollView)
        let simpleTableDependenciesBuilder = SimpleTableDependenciesBuilder(
            document: document,
            router: router,
            handler: actionHandler,
            pasteboardService: pasteboardService,
            markdownListener: markdownListener,
            focusSubjectHolder: focusSubjectHolder,
            viewInput: viewInput,
            mainEditorSelectionManager: blocksStateManager,
            responderScrollViewHelper: responderScrollViewHelper,
            pageService: serviceLocator.pageService(),
            linkToObjectCoordinator: coordinatorsDI.linkToObject().make(browserController: browser)
        )

        let blocksConverter = BlockViewModelBuilder(
            document: document,
            handler: actionHandler,
            pasteboardService: pasteboardService,
            router: router,
            delegate: blockDelegate,
            markdownListener: markdownListener,
            simpleTableDependenciesBuilder: simpleTableDependenciesBuilder,
            subjectsHolder: focusSubjectHolder,
            pageService: serviceLocator.pageService(),
            detailsService: serviceLocator.detailsService(objectId: document.objectId)
        )

        actionHandler.blockSelectionHandler = blocksStateManager

        blocksStateManager.blocksSelectionOverlayViewModel = blocksSelectionOverlayViewModel
        blocksStateManager.blocksOptionViewModel = blocksOptionViewModel
        
        let editorPageTemplatesHandler = EditorPageTemplatesHandler()
        
        return EditorPageViewModel(
            document: document,
            viewInput: viewInput,
            blockDelegate: blockDelegate,
            router: router,
            modelsHolder: modelsHolder,
            blockBuilder: blocksConverter,
            actionHandler: actionHandler,
            headerModel: headerModel,
            blockActionsService: blockActionsServiceSingle,
            blocksStateManager: blocksStateManager,
            cursorManager: cursorManager,
            objectActionsService: serviceLocator.objectActionsService(),
            searchService: serviceLocator.searchService(),
            editorPageTemplatesHandler: editorPageTemplatesHandler,
            accountManager: serviceLocator.accountManager(),
            isOpenedForPreview: isOpenedForPreview
        )
    }

    private func buildBlocksSelectionOverlayView(
        simleTableMenuViewModel: SimpleTableMenuViewModel,
        blockOptionsViewViewModel: SelectionOptionsViewModel
    ) -> BlocksSelectionOverlayView {
        let blocksOptionView = SelectionOptionsView(viewModel: blockOptionsViewViewModel)
        let blocksSelectionOverlayViewModel = BlocksSelectionOverlayViewModel()

        return BlocksSelectionOverlayView(
            viewModel: blocksSelectionOverlayViewModel,
            blocksOptionView: blocksOptionView,
            simpleTablesOptionView: SimpleTableMenuView(viewModel: simleTableMenuViewModel)
        )
    }
    
    private func favoritesModule(output: WidgetObjectListCommonModuleOutput?) -> (UIViewController, EditorPageOpenRouterProtocol?) {
        let moduleAssembly = modulesDI.widgetObjectList()
        let module = moduleAssembly.makeFavorites(output: output)
        return (module, nil)
    }
    
    private func recentModule(output: WidgetObjectListCommonModuleOutput?) -> (UIViewController, EditorPageOpenRouterProtocol?) {
        let moduleAssembly = modulesDI.widgetObjectList()
        let module = moduleAssembly.makeRecent(output: output)
        return (module, nil)
    }

    private func setsModule(output: WidgetObjectListCommonModuleOutput?) -> (UIViewController, EditorPageOpenRouterProtocol?) {
        let moduleAssembly = modulesDI.widgetObjectList()
        let module = moduleAssembly.makeSets(output: output)
        return (module, nil)
    }

}
