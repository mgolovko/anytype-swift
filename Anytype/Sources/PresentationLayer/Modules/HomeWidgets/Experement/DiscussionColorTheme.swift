import Foundation
import SwiftUI

struct DiscussionSetings {
    let showHeader: Bool
}

struct DiscussionSettingsKey: EnvironmentKey {
    static let defaultValue = DiscussionSetings(showHeader: true)
}

extension EnvironmentValues {
    var discussionSettings: DiscussionSetings {
        get { self[DiscussionSettingsKey.self] }
        set { self[DiscussionSettingsKey.self] = newValue }
    }
}

struct DiscussionColorTheme {
    let yourMesssageBackground: Color
    let messageBackground: Color
    let listBackground: Color
    let inputAreaBackground: Color
    let inputBackground1Layer: Color
    let inputBackground2Layer: Color
    let inputPrimaryAction: Color
    let inputAction: Color
}

extension DiscussionColorTheme {
    static let editor = DiscussionColorTheme(
        yourMesssageBackground: .VeryLight.green,
        messageBackground: .VeryLight.grey,
        listBackground: .Background.primary,
        inputAreaBackground: .Background.primary,
        inputBackground1Layer: .Navigation.background,
        inputBackground2Layer: .clear,
        inputPrimaryAction: .Button.button,
        inputAction: .Button.active
    )
    
    static let home = DiscussionColorTheme(
        yourMesssageBackground: .VeryLight.green,
        messageBackground: .VeryLight.grey,
        listBackground: .clear,
        inputAreaBackground: .clear,
        inputBackground1Layer: .Widget.bottomPanel,
        inputBackground2Layer: .clear,
        inputPrimaryAction: .Experement.widgetIconNewColor,
        inputAction: .Experement.widgetIconNewColor
    )
}


struct DiscussionColorThemeKey: EnvironmentKey {
    static let defaultValue = DiscussionColorTheme(
        // Use any random colors to detect problem with environment
        yourMesssageBackground: .red,
        messageBackground: .gray,
        listBackground: .orange,
        inputAreaBackground: .orange,
        inputBackground1Layer: .red,
        inputBackground2Layer: .orange,
        inputPrimaryAction: .orange,
        inputAction: .blue
    )
}

extension EnvironmentValues {
    var discussionColorTheme: DiscussionColorTheme {
        get { self[DiscussionColorThemeKey.self] }
        set { self[DiscussionColorThemeKey.self] = newValue }
    }
}
