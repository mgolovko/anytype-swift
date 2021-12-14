import BlocksModels

extension Array where Element == BlockRestrictions {
    var mergedOptions: Set<BlocksOptionItem> {
        var options = Set(BlocksOptionItem.allCases)

        forEach { element in
            if !element.canDeleteOrDuplicate {
                options.remove(.delete)
                options.remove(.duplicate)
            }

            if !element.canCreateBlockBelowOnEnter {
                options.remove(.addBlockBelow)
            }

            if !element.canApplyStyle(.smartblock(.page)) {
                options.remove(.turnInto)
            }
        }

        if count > 1 {
            options.remove(.addBlockBelow)
        }

        return options
    }
}

extension Array where Element == BlockInformation {
    var blocksOptionItems: [BlocksOptionItem] {
        var isDownloadAvailable = true

        var restrictions = [BlockRestrictions]()

        forEach { element in
            if case let .file(type) = element.content {
                if type.state != .done { isDownloadAvailable = false }
            } else {
                isDownloadAvailable = false
            }

            let restriction = BlockRestrictionsBuilder.build(contentType: element.content.type)
            restrictions.append(restriction)
        }

        var mergedItems = restrictions.mergedOptions

        if !isDownloadAvailable || count > 1 {
            mergedItems.remove(.download)
        }

        return Array<BlocksOptionItem>(mergedItems).sorted()
    }
}
