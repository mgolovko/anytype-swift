import Foundation
import FloatingPanel
import CoreGraphics

class FixedHeightFloatingPanelLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full
    
    let height: CGFloat
    
    init(height: CGFloat) {
        self.height = height
    }
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: height, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
}
