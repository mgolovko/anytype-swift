import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

struct ObjectCreationSetting {
    let objectTypeId: BlockId
    let templateId: BlockId
}

@MainActor
final class SetObjectCreationSettingsViewModel: ObservableObject {
    @Published var isEditingState = false
    @Published var objectTypes = [InstalledObjectTypeViewModel]()
    @Published var templates = [TemplatePreviewViewModel]()
    @Published var canChangeObjectType = false
    
    var title: String {
        if canChangeObjectType {
            return interactor.mode.title
        } else {
            return Loc.Set.View.Settings.DefaultTemplate.title
        }
    }
    
    var isTemplatesAvailable = true
    
    var templateEditingHandler: ((ObjectCreationSetting) -> Void)?
    var onObjectTypesSearchAction: (() -> Void)?
    
    private var userTemplates = [TemplatePreviewModel]() {
        didSet {
            updateTemplatesList()
        }
    }
    
    private let interactor: SetObjectCreationSettingsInteractorProtocol
    private let setDocument: SetDocumentProtocol
    private let templatesService: TemplatesServiceProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let onTemplateSelection: (ObjectCreationSetting) -> Void
    private var cancellables = [AnyCancellable]()
    
    init(
        interactor: SetObjectCreationSettingsInteractorProtocol,
        setDocument: SetDocumentProtocol,
        templatesService: TemplatesServiceProtocol,
        toastPresenter: ToastPresenterProtocol,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> Void
    ) {
        self.interactor = interactor
        self.setDocument = setDocument
        self.templatesService = templatesService
        self.toastPresenter = toastPresenter
        self.onTemplateSelection = onTemplateSelection
        
        updateTemplatesList()
        
        setupSubscriptions()
    }
    
    func onTemplateTap(model: TemplatePreviewModel) {
        switch model.mode {
        case .installed(let templateModel):
            onTemplateSelect(
                objectTypeId: interactor.objectTypeId.rawValue,
                templateId: templateModel.id
            )
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: templateModel.isBundled ? .object(typeId: templateModel.id) : .custom,
                route: setDocument.isCollection() ? .collection : .set
            )
        case .blank:
            onTemplateSelect(
                objectTypeId: interactor.objectTypeId.rawValue,
                templateId: ""
            )
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: nil,
                route: setDocument.isCollection() ? .collection : .set
            )
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onTemplateSelect(objectTypeId: BlockId, templateId: BlockId) {
        if interactor.mode == .default {
            setTemplateAsDefault(templateId: templateId, showMessage: false)
        }
        onTemplateSelection(
            ObjectCreationSetting(
                objectTypeId: objectTypeId,
                templateId: templateId
            )
        )
    }
    
    func onAddTemplateTap() {
        let objectTypeId = interactor.objectTypeId.rawValue
        Task { [weak self] in
            do {
                guard let templateId = try await self?.templatesService.createTemplateFromObjectType(objectTypeId: objectTypeId) else {
                    return
                }
                AnytypeAnalytics.instance().logTemplateCreate(objectType: .object(typeId: objectTypeId))
                self?.templateEditingHandler?(
                    ObjectCreationSetting(objectTypeId: objectTypeId, templateId: templateId)
                )
                self?.toastPresenter.showObjectCompositeAlert(
                    prefixText: Loc.Templates.Popup.wasAddedTo,
                    objectId: self?.interactor.objectTypeId.rawValue ?? "",
                    tapHandler: { }
                )
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    func setObjectTypeId(_ objectTypeId: String) {
        guard let objectTypeId = ObjectTypeId(rawValue: objectTypeId) else { return }
        switch interactor.mode {
        case .creation:
            interactor.setObjectTypeId(objectTypeId)
        case .default:
            setObjectTypeAsDefault(objectTypeId: objectTypeId.rawValue)
        }
        
    }
    
    func setTemplateAsDefault(templateId: BlockId, showMessage: Bool) {
        Task {
            do {
                try await interactor.setDefaultTemplate(templateId: templateId)
                if showMessage {
                    toastPresenter.show(message: Loc.Templates.Popup.default)
                }
            }
        }
    }
    
    private func setObjectTypeAsDefault(objectTypeId: BlockId) {
        Task {
            do {
                try await interactor.setDefaultObjectType(objectTypeId: objectTypeId)
            }
        }
    }
    
    private func setupSubscriptions() {
        // Templates
        interactor.userTemplates.sink { [weak self] templates in
            if let userTemplates = self?.userTemplates,
                userTemplates != templates {
                self?.userTemplates = templates
            }
        }.store(in: &cancellables)
        
        // Object types
        interactor.objectTypesAvailabilityPublisher.sink { [weak self] canChangeObjectType in
            self?.canChangeObjectType = canChangeObjectType
        }.store(in: &cancellables)
        
        interactor.objectTypesConfigPublisher.sink { [weak self] objectTypesConfig in
            guard let self else { return }
            let defaultObjectType = objectTypesConfig.objectTypes.first {
                $0.id == objectTypesConfig.objectTypeId.rawValue
            }
            isTemplatesAvailable = defaultObjectType?.recommendedLayout.isTemplatesAvailable ?? false
            updateObjectTypes(objectTypesConfig)
        }.store(in: &cancellables)
    }
    
    private func updateObjectTypes(_ objectTypesConfig: ObjectTypesConfiguration) {
        var convertedObjectTypes = objectTypesConfig.objectTypes.map {  type in
            let isSelected = type.id == objectTypesConfig.objectTypeId.rawValue
            return InstalledObjectTypeViewModel(
                id: type.id,
                icon: .object(.emoji(type.iconEmoji)),
                title: type.name,
                isSelected: isSelected,
                onTap: { [weak self] in
                    self?.setObjectTypeId(type.id)
                }
            )
        }
        let searchItem = InstalledObjectTypeViewModel(
            id: InstalledObjectTypeViewModel.searchId,
            icon: .asset(.X18.search),
            title: nil,
            isSelected: false,
            onTap: { [weak self] in
                self?.onObjectTypesSearchAction?()
            }
        )
        convertedObjectTypes.insert(searchItem, at: 0)
        objectTypes = convertedObjectTypes
    }
    
    private func handleTemplateOption(
        option: TemplateOptionAction,
        templateViewModel: TemplatePreviewModel
    ) {
        let objectTypeId = interactor.objectTypeId.rawValue
        Task {
            do {
                switch option {
                case .delete:
                    try await templatesService.deleteTemplate(templateId: templateViewModel.id)
                    toastPresenter.show(message: Loc.Templates.Popup.removed)
                case .duplicate:
                    try await templatesService.cloneTemplate(blockId: templateViewModel.id)
                    toastPresenter.show(message: Loc.Templates.Popup.duplicated)
                case .editTemplate:
                    templateEditingHandler?(
                        ObjectCreationSetting(objectTypeId: objectTypeId, templateId: templateViewModel.id)
                    )
                case .setAsDefault:
                    setTemplateAsDefault(
                        templateId: templateViewModel.id,
                        showMessage: interactor.mode == .creation
                    )
                }
                
                handleAnalytics(option: option, templateViewModel: templateViewModel)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    private func handleAnalytics(option: TemplateOptionAction, templateViewModel: TemplatePreviewModel) {
        guard case let .installed(templateModel) = templateViewModel.mode else {
            return
        }
        
        let objectType: AnalyticsObjectType = templateModel.isBundled ? .object(typeId: templateModel.id) : .custom
        
        
        switch option {
        case .editTemplate:
            AnytypeAnalytics.instance().logTemplateEditing(objectType: objectType, route: setDocument.isCollection() ? .collection : .set)
        case .delete:
            AnytypeAnalytics.instance().logMoveToBin(true)
        case .duplicate:
            AnytypeAnalytics.instance().logTemplateDuplicate(objectType: objectType, route: setDocument.isCollection() ? .collection : .set)
        case .setAsDefault:
            break // Interactor resposibility
        }
    }
    
    private func updateTemplatesList() {
        var templates = [TemplatePreviewModel]()

        if !userTemplates.contains(where: { $0.isDefault }) {
            templates.append(.init(mode: .blank, alignment: .left, isDefault: true))
        } else {
            templates.append(.init(mode: .blank, alignment: .left, isDefault: false))
        }
        
        templates.append(contentsOf: userTemplates)
        templates.append(.init(mode: .addTemplate, alignment: .center, isDefault: false))
        
        withAnimation {
            self.templates = templates.map { model in
                TemplatePreviewViewModel(
                    model: model,
                    onOptionSelection: { [weak self] option in
                        self?.handleTemplateOption(option: option, templateViewModel: model)
                    }
                )
            }
        }
    }
}

extension TemplatePreviewModel {
    init(objectDetails: ObjectDetails, isDefault: Bool) {
        self = .init(
            mode: .installed(.init(
                id: objectDetails.id,
                title: objectDetails.title,
                header: HeaderBuilder.buildObjectHeader(
                    details: objectDetails,
                    usecase: .templatePreview,
                    presentationUsecase: .editor,
                    onIconTap: {},
                    onCoverTap: {}
                ),
                isBundled: objectDetails.templateIsBundled,
                style: objectDetails.layoutValue == .todo ? .todo(objectDetails.isDone) : .none
            )
            ),
            alignment: objectDetails.layoutAlignValue,
            isDefault: isDefault
        )
    }
}

extension TemplatePreviewModel {
    var isEditable: Bool {
        switch mode {
        case .blank, .installed:
            return true
        case .addTemplate:
            return false
        }
    }
}