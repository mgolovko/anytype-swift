//
//  DocumentDetailsViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 30.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Combine
import BlocksModels

final class DocumentDetailsViewModel {

    private var coverViewState: DocumentCoverViewState = .empty
    private var iconViewState: DocumentIconViewState = .empty
    private var layout: DetailsLayout = .basic
    
    private var subscriptions: [AnyCancellable] = []
    
    private let onUpdate: () -> Void
    
    // MARK: - Initializer
    
    init(onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate
        
        setupSubscriptions()
    }
    
    // MARK: - Internal functions
    
    func performUpdateUsingDetails(_ detailsData: DetailsData) {
        layout = detailsData.layout ?? .basic
        
        coverViewState = detailsData.documentCover.flatMap {
            DocumentCoverViewState.cover($0)
        } ?? DocumentCoverViewState.empty
        
        iconViewState = detailsData.icon.flatMap {
            DocumentIconViewState.icon($0)
        } ?? DocumentIconViewState.empty
        
        onUpdate()
    }
    
    func makeDocumentSection() -> DocumentSection {
        DocumentSection(
            iconViewState: iconViewState,
            coverViewState: coverViewState,
            layout: layout
        )
    }
    
}

private extension DocumentDetailsViewModel {
    
    func setupSubscriptions() {
        NotificationCenter.Publisher(
            center: .default,
            name: .documentCoverImageUploadingEvent,
            object: nil
        )
        .compactMap { $0.object as? String }
        .compactMap { UIImage(contentsOfFile: $0) }
        .receiveOnMain()
        .sink { [weak self] image in
            guard let self = self else { return }
            
            self.coverViewState = .preview(image)
            self.onUpdate()
        }
        .store(in: &subscriptions)
        
        NotificationCenter.Publisher(
            center: .default,
            name: .documentIconImageUploadingEvent,
            object: nil
        )
        .compactMap { $0.object as? String }
        .compactMap { UIImage(contentsOfFile: $0) }
        .receiveOnMain()
        .sink { [weak self] image in
            guard let self = self else { return }
            
            self.iconViewState = {
                switch self.layout {
                case .basic:
                    return .preview(.basic(image))
                case .profile:
                    return .preview(.profile(image))
                }
            }()
            
            self.onUpdate()
        }
        .store(in: &subscriptions)
    }
    
}
