import Services
import SwiftUI


extension SyncStatusInfo {
    static let defaultNetworkTitle = Loc.connecting
    static let defaultNetworkSubtitle = ""
    static let defaultnetworkIcon = ImageAsset.SyncStatus.syncOffline
    static let defaultNetworkIconColor = SyncStatusInfo.NetworkIconBackground.static(Color.Shape.secondary)
}

// Texts
extension SyncStatusInfo {
    var networkTitle: String {
        switch network {
        case .anytype:
            Loc.anytypeNetwork
        case .selfHost:
            Loc.selfHost
        case .localOnly:
            Loc.localOnly
        case .UNRECOGNIZED:
            Self.defaultNetworkTitle
        }
    }
    
    var networkSubtitle: String {
        switch network {
        case .anytype:
            anytypeNetworkSubtitle
        case .selfHost:
            anytypeSelfhostSubtitle
        case .localOnly:
            Loc.SyncStatus.Info.localOnly
        case .UNRECOGNIZED:
            Self.defaultNetworkSubtitle
        }
    }
    
    private var anytypeNetworkSubtitle: String {
        switch self.status {
        case .synced:
            Loc.SyncStatus.Info.anytypeNetwork
        case .syncing:
            Loc.itemsSyncing(Int(syncingObjectsCounter))
        case .error:
            error.localizedDescription
        case .offline:
            Loc.noConnection
        case .UNRECOGNIZED:
            Loc.connecting
        }
    }
    
    private var anytypeSelfhostSubtitle: String {
        switch self.status {
        case .synced:
            Loc.synced
        case .syncing:
            Loc.itemsSyncing(Int(syncingObjectsCounter))
        case .error:
            error.localizedDescription
        case .offline:
            Loc.noConnection
        case .UNRECOGNIZED:
            Loc.connecting
        }
    }
}

// Icon
extension SyncStatusInfo {
    enum NetworkIconBackground: Equatable {
        case `static`(Color)
        case animation(start: Color, end: Color)
        
        var initialColor: Color {
            switch self {
            case .static(let color):
                color
            case .animation(let start, _):
                start
            }
        }
    }
    
    var networkIcon: ImageAsset {
        switch network {
        case .anytype:
            anytypeNetworkIcon
        case .selfHost:
            selfHostIcon
        case .localOnly:
            localOnlyIcon
        case .UNRECOGNIZED:
            ImageAsset.SyncStatus.syncOffline
        }
    }
    
    var networkIconColor: SyncStatusInfo.NetworkIconBackground {
        switch self.network {
        case .anytype, .selfHost:
            networkIconColorBasedOnStatus
        case .localOnly, .UNRECOGNIZED:
            Self.defaultNetworkIconColor
        }
    }
    
    private var networkIconColorBasedOnStatus: SyncStatusInfo.NetworkIconBackground {
        switch status {
        case .synced:
            .static(.Light.green)
        case .syncing:
            .animation(start: .Light.green, end: .Light.green.opacity(0.5))
        case .error:
            .static(.Light.red)
        case .offline, .UNRECOGNIZED:
            .static(.Shape.secondary)
        }
    }
    
    private var anytypeNetworkIcon: ImageAsset {
        switch status {
        case .synced, .syncing:
            ImageAsset.SyncStatus.syncAnytypenetworkConnected
        case .error:
            ImageAsset.SyncStatus.syncAnytypenetworkError
        case .offline, .UNRECOGNIZED:
            ImageAsset.SyncStatus.syncOffline
        }
    }
    
    private var selfHostIcon: ImageAsset {
        switch self.status {
        case .synced, .syncing:
            ImageAsset.SyncStatus.syncSelfhostConnected
        case .error:
            ImageAsset.SyncStatus.syncSelfhostError
        case .offline, .UNRECOGNIZED:
            ImageAsset.SyncStatus.syncSelfhostDefault
        }
    }
    
    private var localOnlyIcon: ImageAsset {
        ImageAsset.SyncStatus.syncLocalonlyDefault
    }
}
