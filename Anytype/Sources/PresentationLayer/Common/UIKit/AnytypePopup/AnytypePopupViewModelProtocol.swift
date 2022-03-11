import Foundation
import UIKit.UIViewController
import FloatingPanel

protocol AnytypePopupViewModelProtocol {
    
    var popupLayout: FloatingPanelLayout { get }
    
    func onPopupInstall(_ popup: AnytypePopupProxy)
    
    func makeContentView() -> UIViewController
    
}
