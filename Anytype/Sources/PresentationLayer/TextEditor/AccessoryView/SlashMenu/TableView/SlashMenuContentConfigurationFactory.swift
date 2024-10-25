import UIKit
import SwiftUI

final class SlashMenuContentConfigurationFactory {
    func dividerConfiguration(title: String) -> any UIContentConfiguration {
        UIHostingConfiguration {
            SectionHeaderView(title: title)
        }
        .minSize(height: 0)
        .margins(.vertical, 0)
    }
    
    func configuration(displayData: SlashMenuItemDisplayData) -> any UIContentConfiguration {
        EditorSearchCellConfiguration(
            cellData: EditorSearchCellData(
                title: displayData.title,
                subtitle: displayData.subtitle ?? "",
                icon: displayData.iconData,
                expandedIcon: displayData.expandedIcon
            )
        )
    }

    func configuration(relation: Relation) -> any UIContentConfiguration {
        SlashMenuRealtionContentConfiguration(relation: RelationItemModel(relation: relation))
    }
}
