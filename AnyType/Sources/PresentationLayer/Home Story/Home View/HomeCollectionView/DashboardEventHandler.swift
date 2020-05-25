//
//  DashboardEventHandler.swift
//  AnyType
//
//  Created by Batvinkin Denis on 22.03.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
  static let dashboardEventHandler: Self = "Services.DashboardEventHandler"
}

extension HomeCollectionViewModel: EventHandler {
    typealias Event = Anytype_Event.Message.OneOf_Value

	func handleEvent(event: Event) {
		switch event {
		case .blockSetLink(let setLink):
			self.updatePages(setLink: setLink)
			break
		case .blockShow(let blockShow):
			self.processPages(blockShow: blockShow)
		case .blockAdd(let addBlock):
			self.addPage(addBlock: addBlock)
		default:
		  let logger = Logging.createLogger(category: .dashboardEventHandler)
		  os_log(.debug, log: logger, "we handle only events above. Event %@ isn't handled", String(describing: event))
			return
		}
	}
}

extension HomeCollectionViewModel {
    // TODO: Rethink current implementation.
    // We should build DashboardView on top of DocumentViewModel.
    // In this case we could take all updates for nothing.
    private func parser() -> BlockModels.Parser {
        .init()
    }
    private func convert(page: Anytype_Model_Block?, details: Anytype_Event.Block.Set.Details?) -> DashboardPage? {
        guard let page = page, case let .link(value) = page.content, let details = details else {
            return nil
        }
        let convertedDetails = BlockModels.Parser.PublicConverters.EventsDetails.convert(event: details)
        let correctedDetails = BlockModels.Parser.Details.Converter.asModel(details: convertedDetails)
        let ourDetails = BlockModels.Block.Information.PageDetails.init(correctedDetails)
        return .init(id: page.id, targetBlockId: value.targetBlockID, title: ourDetails.title?.text, iconEmoji: ourDetails.iconEmoji?.text, style: value)
    }
    private func convert(pages: [Anytype_Model_Block], details: [Anytype_Event.Block.Set.Details]) -> [DashboardPage] {
        let dictionary: [String: Anytype_Model_Block] = .init(uniqueKeysWithValues: pages.map({ value in
            switch value.content {
            case let .link(link): return (link.targetBlockID, value)
            default: return (value.id, value)
            }
        }))
        let result = details.reduce([DashboardPage]()) { (result, value) in
            let structure = dictionary[value.id]
            var result = result
            if let page = self.convert(page: structure, details: value) {
                result.append(page)
            }
            return result
        }
        return result
    }
    
    // MARK: - Page processing
    /// Sorting pages according to order in rootPage.childrenIds.
    /// - Parameters:
    ///   - rootId: the Id of root page.
    ///   - pages: [rootPage] + rootPage.pages
    private func processPages(blockShow: Anytype_Event.Block.Show) {
        self.rootId = blockShow.rootID
        let pages = blockShow.blocks

        // obtain root page
        guard let rootPage = pages.first(where: { $0.id == rootId }) else { return }
        let indices = rootPage.childrenIds

        let ourPages = self.convert(pages: pages, details: blockShow.details)
        
        // sort pages
        let dictionary: [String: DashboardPage] = .init(uniqueKeysWithValues: ourPages.map({($0.id, $0)}))

        self.dashboardPages = indices.compactMap { dictionary[$0] }
    }

    private func addPage(addBlock: Anytype_Event.Block.Add) {
        self.dashboardPages += self.convert(pages: addBlock.blocks, details: [])
    }

    private func updatePages(setLink: Anytype_Event.Block.Set.Link) {
        return
        guard setLink.hasFields, setLink.fields.hasValue else { return }

        // find page
        var pageToUpdate = self.dashboardPages.first(where: { page -> Bool in
            page.id == setLink.id
        })

        // update page
//        pageToUpdate?.fields.fields["name"] = setLink.fields.value.fields["name"]
        // TODO: add update icon
    }
}
