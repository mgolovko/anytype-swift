import Foundation

public extension FeatureDescription {
    
    static let setKanbanView = FeatureDescription(
        title: "Set kanban view",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let fullInlineSetImpl = FeatureDescription(
        title: "Full inline set impl (IOS-790)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let dndOnCollectionsAndSets = FeatureDescription(
        title: "Dnd on collections and sets (wating for the middle)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false
    )
    
    static let migrationGuide = FeatureDescription(
        title: "Migration guide",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let fileStorage = FeatureDescription(
        title: "File storage",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let newAuthorization = FeatureDescription(
        title: "New authorization",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let redesignAbout = FeatureDescription(
        title: "Redesign about",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let sortIncludeTime = FeatureDescription(
        title: "Sort include time",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let binConfirmAlert = FeatureDescription(
        title: "Bin confirm alert",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let fixSIGPIPECrash = FeatureDescription(
        title: "Fix SIGPIPE crash",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let compactListWidget = FeatureDescription(
        title: "Compact List widget",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: true
    )
    
    static let getMoreSpace = FeatureDescription(
        title: "Get more space - IOS-1307",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: true
    )
    
    // MARK: - Debug
    
    static let rainbowViews = FeatureDescription(
        title: "Paint editor views 🌈",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
    
    static let showAlertOnAssert = FeatureDescription(
        title: "Show alerts on asserts\n(only for test builds)",
        type: .debug,
        defaultValue: true
    )
    
    static let analytics = FeatureDescription(
        title: "Analytics - send events to Amplitude (only for test builds)",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
    
    static let analyticsAlerts = FeatureDescription(
        title: "Analytics - show alerts",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
}
