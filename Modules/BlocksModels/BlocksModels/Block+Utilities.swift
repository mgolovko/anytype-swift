//
//  Block+Utilities.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let blocksModelsIndexWalker: Self = "BlocksModels.Utilities.IndexWalker"
}

fileprivate typealias Namespace = Block
fileprivate typealias FileNamespace = Namespace.Utilities

public extension Namespace {
    enum Utilities {}
}

public extension FileNamespace {
    // TODO: Implement custom Debug for our models.
    enum Debug {
        static let maxDotsRepeating = 10
        public static func output(_ model: BlockModelProtocol) -> [String] {
            []
            // NOTE: Do not remove until you implement debug for all models.
            // It is example of fine output.
//            let result = BlockModels.Transformer.FromTreeToListTransformer().toList(model)
//            let output = result.map({ value -> String in
//                let indentationLevel = value.indentationLevel()
//                let section = value.indexPath.section
//                let repeatingCount = min(Int(section), maxDotsRepeating)
//                let indentation = Array(repeating: "..", count: repeatingCount).joined()
//                let information = value.information.content
//                return "\(indentation) -> \(value.indexPath) <- \(value.kind) | \(information)"
//            })
//            return output
        }
    }
}

extension FileNamespace {
    enum InformationIdentifier {
        typealias Information = BlockInformationModelProtocolWithHashable
        
        struct Diffable<Wrapped: BlockInformationModelProtocolWithHashable>: Hashable {
            var value: Wrapped
        }
        
        static func identifier<T: Information>(for information: T) -> Diffable<T> {
            .init(value: information)
        }
    }
}

public extension FileNamespace {
    enum IndexWalker {
        public typealias Model = BlockActiveRecordModelProtocol
        
        public static func model(beforeModel model: Model, includeParent: Bool) -> Model? {
            guard let parent = model.findParent() else {
                // hm.. we don't have parent?
                let logger = Logging.createLogger(category: .blocksModelsIndexWalker)
                os_log(.debug, log: logger, "We don't have parent for model %@, so, we should return something?", "\(model.blockModel.information.id)")
                return nil
            }
            
            let id = model.blockModel.information.id
            let childrenIds = parent.childrenIds()
            
            guard let childIndex = childrenIds.firstIndex(where: {$0 == id}) else {
                // Heh, again, we can't find ourselves in parent.
                let logger = Logging.createLogger(category: .blocksModelsIndexWalker)
                os_log(.debug, log: logger, "We can't find ourselves (%@) in parent, so, skip it.", "\(model.blockModel.information.id)")
                return nil
            }

            if childrenIds.startIndex == childIndex {
                // move to parent
                guard includeParent else { return nil }
                return self.model(beforeModel: parent, includeParent: includeParent)
            }
            else {
                let beforeIndex = childrenIds.index(before: childIndex)
                let beforeIndexId = childrenIds[beforeIndex]
                return parent.container?.choose(by: beforeIndexId)
            }
        }
    }
}

public extension FileNamespace {
    enum FirstResponderResolver {
        public typealias Model = BlockActiveRecordModelProtocol
        
        public static func resolvePendingUpdate(_ model: Model) {
            model.container?.userSession.didChange()
        }
        
        public static func resolve(_ model: Model) {
            if model.isFirstResponder {
                var model = model
                model.unsetFirstResponder()
                model.unsetFocusAt()
            }
        }
    }
}

/// It is necessary to determine a kind of content in terms of something "Hashable and Equatable"
/// Actually, we could use `-> AnyHashable` type here as result type.
/// But it is fine to use `String` here.
public extension FileNamespace {
    enum ContentTypeIdentifier {
        public typealias Content = TopLevel.AliasesMap.BlockContent
        public typealias Identifier = String
        private static func subIdentifier(_ content: Content.Text) -> Identifier {
            switch content.contentType {
            case .text: return ".text"
            case .header: return ".header"
            case .header2: return ".header2"
            case .header3: return ".header3"
            case .header4: return ".header4"
            case .quote: return ".quote"
            case .checkbox: return ".checkbox"
            case .bulleted: return ".bulleted"
            case .numbered: return ".numbered"
            case .toggle: return ".toggle"
            case .callout: return ".callout"
            }
        }
        public static func identifier(_ content: Content) -> Identifier {
            switch content {
            case .smartblock(_): return ".smartblock"
            case let .text(value): return ".text" + self.subIdentifier(value)
            case .file(_): return ".file"
            case .divider(_): return ".divider"
            case .bookmark(_): return ".bookmark"
            case .link(_): return ".link"
            }
        }
    }
}


public extension FileNamespace {
    /// The main purpose of this inspector is to identify kind of details.
    /// It could be done by parsing identifier of Information that was built from concrete detail.
    ///
    /// Prerequisites:
    ///
    /// 1. Build Information from Details.
    ///
    enum DetailsInspector {
        public typealias Kind = TopLevel.AliasesMap.DetailsContent.Kind
        public typealias Id = TopLevel.AliasesMap.BlockId
        public typealias Details = TopLevel.AliasesMap.DetailsContent
        /// It parses identifier and try to figure our the kind of a detail.
        /// - Parameter id: Id of Information that is built from detail.
        /// - Returns: Kind of detail.
        ///
        public static func kind(of id: Id) -> Kind? {
            let (_, details) = Block.Information.DetailsAsBlockConverter.IdentifierBuilder.asDetails(id)
            switch details {
            case Details.Title.id: return .title
            case Details.Emoji.id: return .iconEmoji
            default: return nil
            }
        }
    }
}
