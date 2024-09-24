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
}

extension DiscussionColorTheme {
    static let editor = DiscussionColorTheme(
        yourMesssageBackground: .VeryLight.green,
        messageBackground: .VeryLight.grey,
        listBackground: .Background.primary,
        inputAreaBackground: .Background.primary
    )
    
    static let home = DiscussionColorTheme(
        yourMesssageBackground: .VeryLight.green,
        messageBackground: .VeryLight.grey,
        listBackground: .clear,
        inputAreaBackground: .clear
    )
}


struct DiscussionColorThemeKey: EnvironmentKey {
    static let defaultValue = DiscussionColorTheme(
        // Use any random colors to detect problem with environment
        yourMesssageBackground: .red,
        messageBackground: .gray,
        listBackground: .orange,
        inputAreaBackground: .orange
    )
}

extension EnvironmentValues {
    var discussionColorTheme: DiscussionColorTheme {
        get { self[DiscussionColorThemeKey.self] }
        set { self[DiscussionColorThemeKey.self] = newValue }
    }
}
