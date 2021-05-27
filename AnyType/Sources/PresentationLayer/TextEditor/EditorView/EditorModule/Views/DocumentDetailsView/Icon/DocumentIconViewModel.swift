import Combine
import UIKit
import BlocksModels

final class DocumentIconViewModel {
    
    var onMediaPickerImageSelect: ((_ imagePath: String) -> Void)?

    let documentIcon: DocumentIcon
    
    // MARK: - Private variables
    
    private let fileService = BlockActionsServiceFile()
    
    private let detailsActiveModel: DetailsActiveModel
    private let userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    
    init(documentIcon: DocumentIcon,
         detailsActiveModel: DetailsActiveModel,
         userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>) {
        self.documentIcon = documentIcon
        self.detailsActiveModel = detailsActiveModel
        self.userActionSubject = userActionSubject
    }
    
}

// MARK: - Internal functions

extension DocumentIconViewModel {
    
    // Sorry 🙏🏽
    typealias BlockUserAction = BlocksViews.UserAction
    
    func handleIconUserAction(_ action: DocumentIconViewUserAction) {
        switch action {
        case .select:
            showEmojiPicker()
        case .random:
            setRandomEmoji()
        case .upload:
            showImagePicker()
        case .remove:
            removeIcon()
        }
    }
    
}

// MARK: - Actions handler

private extension DocumentIconViewModel {
    
    func showEmojiPicker() {
        let model = EmojiPicker.ViewModel()
        
        model.$selectedEmoji
            .safelyUnwrapOptionals()
            .sink { [weak self] emoji in
                self?.updateDetails(
                    [
                        DetailsEntry(
                            kind: .iconEmoji,
                            value: emoji.unicode
                        ),
                        DetailsEntry(
                            kind: .iconImage,
                            value: ""
                        )
                    ]
                )
            }
            .store(in: &subscriptions)
        
        userActionSubject.send(
            BlockUserAction.specific(
                BlockUserAction.SpecificAction.page(
                    BlockUserAction.Page.UserAction.emoji(
                        BlockUserAction.Page.UserAction.EmojiAction.shouldShowEmojiPicker(model)
                    )
                )
            )
        )
    }
    
    func showImagePicker() {
        let model = MediaPicker.ViewModel(type: .images)
        model.onResultInformationObtain = { [weak self] resultInformation in
            guard let resultInformation = resultInformation else {
                // show error if needed
                return
            }
            
            guard let self = self else { return }
            
            let localPath = resultInformation.filePath
            
            DispatchQueue.main.async {
                self.onMediaPickerImageSelect?(localPath)
            }
            self.uploadSelectedIconImage(at: localPath)
        }
        
        userActionSubject.send(
            BlockUserAction.specific(
                BlockUserAction.SpecificAction.file(
                    BlockUserAction.File.FileAction.shouldShowImagePicker(
                        .init(model: model)
                    )
                )
            )
        )
    }
    
    func uploadSelectedIconImage(at localPath: String) {
        fileService.uploadFile.action(
            url: "",
            localPath: localPath,
            type: .image,
            disableEncryption: false
        )
        .flatMap { [weak self] uploadedFile in
            self?.detailsActiveModel.update(
                details: [
                    DetailsEntry(
                        kind: .iconEmoji,
                        value: ""
                    ),
                    DetailsEntry(
                        kind: .iconImage,
                        value: uploadedFile.hash
                    )
                ]
            ) ?? .empty()
        }
        .sinkWithDefaultCompletion("uploading image on \(self)") { _ in }
        .store(in: &self.subscriptions)
    }
    
    func setRandomEmoji() {
        let emoji = EmojiPicker.Manager().random()
        
        updateDetails(
            [
                DetailsEntry(
                    kind: .iconEmoji,
                    value: emoji.unicode
                ),
                DetailsEntry(
                    kind: .iconImage,
                    value: ""
                )
            ]
        )
    }
    
    func removeIcon() {
        updateDetails(
            [
                DetailsEntry(
                    kind: .iconEmoji,
                    value: ""
                ),
                DetailsEntry(
                    kind: .iconImage,
                    value: ""
                )
            ]
        )
    }
    
    func updateDetails(_ details: [DetailsEntry<AnyHashable>]) {
        detailsActiveModel.update(
            details: details
        )?.sinkWithDefaultCompletion("Emoji setDetails remove icon emoji") { _ in
            return
        }
        .store(in: &subscriptions)
    }
    
}
