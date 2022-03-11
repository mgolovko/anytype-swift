import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import Amplitude
import AnytypeCore

final class EditorPageViewModel: EditorPageViewModelProtocol {
    weak private(set) var viewInput: EditorPageViewInput?

    let blocksStateManager: EditorPageBlocksStateManagerProtocol

    let document: BaseDocumentProtocol
    let modelsHolder: EditorMainItemModelsHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    private let cursorManager: EditorCursorManager
    let objectSettingsViewModel: ObjectSettingsViewModel
    let actionHandler: BlockActionHandlerProtocol
    let wholeBlockMarkupViewModel: MarkupViewModel
    
    private let blockBuilder: BlockViewModelBuilder
    private let headerBuilder: ObjectHeaderBuilder
    private lazy var cancellables = [AnyCancellable]()

    private let blockActionsService: BlockActionsServiceSingle

    deinit {
        blockActionsService.close(contextId: document.objectId, blockId: document.objectId)

        EventsBunch(
            contextId: MiddlewareConfigurationService.shared.configuration().homeBlockID,
            localEvents: [.documentClosed(blockId: document.objectId)]
        ).send()
    }

    // MARK: - Initialization
    init(
        document: BaseDocumentProtocol,
        viewInput: EditorPageViewInput,
        blockDelegate: BlockDelegate,
        objectSettingsViewModel: ObjectSettingsViewModel,
        router: EditorRouterProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        blockBuilder: BlockViewModelBuilder,
        actionHandler: BlockActionHandler,
        wholeBlockMarkupViewModel: MarkupViewModel,
        headerBuilder: ObjectHeaderBuilder,
        blockActionsService: BlockActionsServiceSingle,
        blocksStateManager: EditorPageBlocksStateManagerProtocol,
        cursorManager: EditorCursorManager
    ) {
        self.objectSettingsViewModel = objectSettingsViewModel
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.blockBuilder = blockBuilder
        self.actionHandler = actionHandler
        self.blockDelegate = blockDelegate
        self.wholeBlockMarkupViewModel = wholeBlockMarkupViewModel
        self.headerBuilder = headerBuilder
        self.blockActionsService = blockActionsService
        self.blocksStateManager = blocksStateManager
        self.cursorManager = cursorManager

        setupSubscriptions()
    }

    private func setupSubscriptions() {
        document.updatePublisher.sink { [weak self] in
            self?.handleUpdate(updateResult: $0)
        }.store(in: &cancellables)
    }
    
    private func updateHeader(_ update: ObjectHeaderUpdate) {
        let details = document.objectDetails
        let header = headerBuilder.updatedHeader(update, details: details)

        updateHeaderIfNeeded(header: header, details: details)
    }
    
    private func handleUpdate(updateResult: DocumentUpdate) {
        switch updateResult {

        case .general:
            performGeneralUpdate()

        case let .details(id):
            guard id == document.objectId else {
                #warning("call blocks update with new details to update mentions/links")
                performGeneralUpdate()
                return
            }
            
            #warning("also we should check if blocks in current object contains mantions/link to current object if YES we must update blocks with updated details")
            let details = document.objectDetails
            let header = headerBuilder.header(details: details)

            objectSettingsViewModel.update(
                objectRestrictions: document.objectRestrictions,
                parsedRelations: document.parsedRelations
            )
            updateHeaderIfNeeded(header: header, details: details)

            let allRelationsBlockViewModel = modelsHolder.items.allRelationViewModel
            let relationIds = allRelationsBlockViewModel.map(\.blockId)
            let diffrerence = difference(with: Set(relationIds))
            modelsHolder.applyDifference(difference: diffrerence)
            viewInput?.update(changes: diffrerence, allModels: modelsHolder.items)

        case let .blocks(updatedIds):
            guard !updatedIds.isEmpty else {
                return
            }
            
            let diffrerence = difference(with: updatedIds)
            updateMarkupViewModel(updatedIds)

            modelsHolder.applyDifference(difference: diffrerence)
            viewInput?.update(changes: diffrerence, allModels: modelsHolder.items)

            updateCursorIfNeeded()
        case .syncStatus(let status):
            viewInput?.update(syncStatus: status)
        case .dataSourceUpdate:
            let models = document.children

            let blocksViewModels = blockBuilder.buildEditorItems(infos: models)
            modelsHolder.items = blocksViewModels

            viewInput?.update(changes: nil, allModels: blocksViewModels)
        case .header(let update):
            updateHeader(update)
        }
    }
    
    private func performGeneralUpdate() {
        handleDeletionState()
        
        let models = document.children
        
        let blocksViewModels = blockBuilder.buildEditorItems(infos: models)
        
        handleGeneralUpdate(with: blocksViewModels)
        
        updateMarkupViewModel(newBlockViewModels: blocksViewModels.onlyBlockViewModels)

        cursorManager.handleGeneralUpdate(with: modelsHolder.items, type: document.objectDetails?.type)
    }
    
    private func handleDeletionState() {
        guard let details = document.objectDetails else {
            anytypeAssertionFailure("No detais for general update", domain: .editorPage)
            return
        }
        
        viewInput?.showDeletedScreen(details.isDeleted)
        if details.isArchived {
            router.goBack()
        }
    }


    private func difference(
        with blockIds: Set<BlockId>
    ) -> CollectionDifference<EditorItem> {
        var currentModels = modelsHolder.items
        
        for (offset, model) in modelsHolder.items.enumerated() {
            guard case let .block(blockViewModel) = model else { continue }
            for blockId in blockIds {
                if blockViewModel.blockId == blockId {
                    guard let model = document.infoContainer.get(id: blockId),
                          let newViewModel = blockBuilder.build(info: model) else {
                              continue
                          }


                    currentModels[offset] = .block(newViewModel)
                }
            }
        }

        return modelsHolder.difference(between: currentModels)
    }
    
    private func updateMarkupViewModel(_ updatedBlockIds: Set<BlockId>) {
        guard let blockIdWithMarkupMenu = wholeBlockMarkupViewModel.blockInformation?.id,
              updatedBlockIds.contains(blockIdWithMarkupMenu) else {
            return
        }
        updateMarkupViewModelWith(informationBy: blockIdWithMarkupMenu)
    }
    
    private func updateMarkupViewModel(newBlockViewModels: [BlockViewModelProtocol]) {
        guard let blockIdWithMarkupMenu = wholeBlockMarkupViewModel.blockInformation?.id else {
            return
        }
        let blockIds = Set(newBlockViewModels.map { $0.blockId })
        guard blockIds.contains(blockIdWithMarkupMenu) else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            return
        }
        updateMarkupViewModelWith(informationBy: blockIdWithMarkupMenu)
    }
    
    private func updateMarkupViewModelWith(informationBy blockId: BlockId) {
        guard let currentInformation = document.infoContainer.get(id: blockId) else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            AnytypeLogger(category: "Editor page view model").debug("Could not find object with id: \(blockId)")
            return
        }
        guard case .text = currentInformation.content else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            return
        }
        wholeBlockMarkupViewModel.blockInformation = currentInformation
    }

    private func handleGeneralUpdate(with models: [EditorItem]) {
        let difference = modelsHolder.difference(between: models)
        if !difference.isEmpty {
            modelsHolder.applyDifference(difference: difference)
        } else {
            modelsHolder.items = models
        }
        
        let details = document.objectDetails
        let header = headerBuilder.header(details: details)
        updateHeaderIfNeeded(header: header, details: details)
        viewInput?.update(changes: difference, allModels: modelsHolder.items)

        objectSettingsViewModel.update(
            objectRestrictions: document.objectRestrictions,
            parsedRelations: document.parsedRelations
        )

        updateCursorIfNeeded()
    }

    private func updateCursorIfNeeded() {
        if let blockFocus = cursorManager.blockFocus,
           let block = modelsHolder.contentProvider(for: blockFocus.id) {

            block.set(focus: blockFocus.position)
            cursorManager.blockFocus = nil
        }
    }

    // iOS 14 bug fix applying header section while editing
    private func updateHeaderIfNeeded(header: ObjectHeader, details: ObjectDetails?) {
        guard modelsHolder.header != header else { return }

        viewInput?.update(header: header, details: details)
        modelsHolder.header = header
    }
}

// MARK: - View output

extension EditorPageViewModel {
    func viewDidLoad() {
        if let objectDetails = document.objectDetails {
            Amplitude.instance().logShowObject(type: objectDetails.type, layout: objectDetails.layout)
        }
    }
    
    func viewWillAppear() {
        guard document.open() else {
            router.goBack()
            return
        }
    }

    func viewDidAppear() {
        cursorManager.didAppeared(with: modelsHolder.items, type: document.objectDetails?.type)
    }
    
    func viewWillDisappear() {
        document.close()
    }
}

// MARK: - Selection Handling

extension EditorPageViewModel {
    func didSelectBlock(at indexPath: IndexPath) {
        element(at: indexPath)?.didSelectRowInTableView()
    }

    func element(at: IndexPath) -> BlockViewModelProtocol? {
        modelsHolder.blockViewModel(at: at.row)
    }
}

extension EditorPageViewModel {
    
    func showSettings() {
        router.showSettings(viewModel: objectSettingsViewModel)
    }
    
    func showIconPicker() {
        router.showIconPicker(viewModel: objectSettingsViewModel.iconPickerViewModel)
    }
    
    func showCoverPicker() {
        router.showCoverPicker(viewModel: objectSettingsViewModel.coverPickerViewModel)
    }
}

// MARK: - Debug

extension EditorPageViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: document.objectId))"
    }
}
