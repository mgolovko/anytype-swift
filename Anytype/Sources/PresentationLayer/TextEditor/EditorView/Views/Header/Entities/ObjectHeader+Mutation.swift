import UIKit

extension ObjectHeader {
    
    func modifiedByLocalEvent(
        _ event: ObjectHeaderLocalEvent,
        onIconTap: @escaping () -> (),
        onCoverTap: @escaping () -> ()
    ) -> ObjectHeader? {
        switch event {
        case .iconUploading(let uIImage):
            return modifiedByIconUploadingEventWith(
                image: uIImage,
                onIconTap: onIconTap
            )
        case .coverUploading(let uIImage):
            return modifiedByCoverUploadingEventWith(
                image: uIImage,
                onCoverTap: onCoverTap
            )
        }
    }
    
    private func modifiedByIconUploadingEventWith(
        image: UIImage,
        onIconTap: @escaping () -> ()
    ) -> ObjectHeader? {
        switch self {
        case .filled(let filledState):
            return .filled(
                filledState.modifiedByIconUploadingEventWith(
                    image: image,
                    onIconTap: onIconTap
                )
            )
            
        case .empty:
            return .filled(
                .iconOnly(
                    ObjectHeaderIcon(
                        icon: .basicPreview(image),
                        layoutAlignment: .left,
                        onTap: onIconTap
                    )
                )
            )
        }
    }
    
    private func modifiedByCoverUploadingEventWith(
        image: UIImage?,
        onCoverTap: @escaping () -> ()
    ) -> ObjectHeader? {
        let newCover = ObjectHeaderCover(
            coverType: .preview(image),
            onTap: onCoverTap
        )
        
        switch self {
        case .filled(let filledState):
            switch filledState {
            case .iconOnly(let objectHeaderIcon):
                return .filled(.iconAndCover(icon: objectHeaderIcon, cover: newCover))
            case .coverOnly:
                return .filled(.coverOnly(newCover))
            case .iconAndCover(let objectHeaderIcon, _):
                return .filled(.iconAndCover(icon: objectHeaderIcon, cover: newCover))
            }
            
        case .empty:
            return .filled(.coverOnly(newCover))
        }
    }
    
}

private extension ObjectHeader.FilledState {
    
    func modifiedByIconUploadingEventWith(
        image: UIImage,
        onIconTap: @escaping () -> ()
    ) -> ObjectHeader.FilledState {
        switch self {
        case .iconOnly(let objectHeaderIcon):
            return .iconOnly(
                objectHeaderIcon.modifiedBy(previewImage: image)
            )
            
        case .coverOnly(let objectCover):
            return .iconAndCover(
                icon: ObjectHeaderIcon(
                    icon: .basicPreview(image),
                    layoutAlignment: .left,
                    onTap: onIconTap
                ),
                cover: objectCover
            )
            
        case .iconAndCover(let objectHeaderIcon, let objectCover):
            return .iconAndCover(
                icon: objectHeaderIcon.modifiedBy(previewImage: image),
                cover: objectCover
            )
        }
    }
    
}

private extension ObjectHeaderIcon {
    
    func modifiedBy(previewImage image: UIImage) -> ObjectHeaderIcon {
        switch self.icon {
        case .icon(let objectIconType):
            switch objectIconType {
            case .basic:
                return ObjectHeaderIcon(
                    icon: .basicPreview(image),
                    layoutAlignment: self.layoutAlignment,
                    onTap: self.onTap
                )
            case .profile:
                return ObjectHeaderIcon(
                    icon: .profilePreview(image),
                    layoutAlignment: self.layoutAlignment,
                    onTap: self.onTap
                )
            case .emoji:
                return ObjectHeaderIcon(
                    icon: .basicPreview(image),
                    layoutAlignment: self.layoutAlignment,
                    onTap: self.onTap
                )
            }
        case .basicPreview:
            return ObjectHeaderIcon(
                icon: .basicPreview(image),
                layoutAlignment: self.layoutAlignment,
                onTap: self.onTap
            )
        case .profilePreview:
            return ObjectHeaderIcon(
                icon: .profilePreview(image),
                layoutAlignment: self.layoutAlignment,
                onTap: self.onTap
            )
        }
    }
    
}
