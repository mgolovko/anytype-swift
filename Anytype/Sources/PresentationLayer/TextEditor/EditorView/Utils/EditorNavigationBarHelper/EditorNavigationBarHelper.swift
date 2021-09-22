import Foundation
import UIKit
import BlocksModels

final class EditorNavigationBarHelper {
    
    private let fakeNavigationBarBackgroundView = UIView()
    private let navigationBarTitleView = EditorNavigationBarTitleView()
    
    private let backBarButtonItemView: EditorBarButtonItemView
    private let settingsBarButtonItemView: EditorBarButtonItemView
    
    private var contentOffsetObservation: NSKeyValueObservation?
    
    private var isObjectHeaderWithCover = false
    private var objectHeaderHeight: CGFloat = 0.0
    
    private(set) var heightConstraint: NSLayoutConstraint?
    
    init(onBackBarButtonItemTap: @escaping () -> Void,
         onSettingsBarButtonItemTap: @escaping () -> Void) {
        self.backBarButtonItemView = EditorBarButtonItemView(
            image: .backArrow,
            action: onBackBarButtonItemTap
        )
        self.settingsBarButtonItemView = EditorBarButtonItemView(
            image: .more,
            action: onSettingsBarButtonItemTap
        )
        
        self.fakeNavigationBarBackgroundView.backgroundColor = .backgroundPrimary
        self.fakeNavigationBarBackgroundView.alpha = 0.0
        
        self.navigationBarTitleView.setAlphaForSubviews(0.0)
    }
    
}

// MARK: - EditorNavigationBarHelperProtocol

extension EditorNavigationBarHelper: EditorNavigationBarHelperProtocol {
    
    func addFakeNavigationBarBackgroundView(to view: UIView) {
        view.addSubview(fakeNavigationBarBackgroundView) {
            $0.top.equal(to: view.topAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            heightConstraint = $0.height.equal(to: 0)
        }
    }
    
    func handleViewWillAppear(_ vc: UIViewController?, _ scrollView: UIScrollView) {
        guard let vc = vc else { return }
        
        configureNavigationItem(in: vc)
        
        contentOffsetObservation = scrollView.observe(
            \.contentOffset,
            options: .new
        ) { [weak self] scrollView, _ in
            let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
            let topInset = scrollView.contentInset.top
            
            self?.updateNavigationBarAppearanceBasedOnContentOffset(offset + topInset)
        }
    }
    
    func handleViewWillDisappear() {
        contentOffsetObservation?.invalidate()
        contentOffsetObservation = nil
    }
    
    func configureNavigationBar(using header: ObjectHeader, details: DetailsDataProtocol?) {
        isObjectHeaderWithCover = header.isWithCover
        objectHeaderHeight = header.height
        
        updateBarButtonItemsBackground(alpha: isObjectHeaderWithCover ? 1.0 : 0.0)
        
        let title: String = {
            guard
                let string = details?.name, !string.isEmpty
            else {
                return "Untitled".localized
            }
            
            return string
        }()
        
        navigationBarTitleView.configure(
            model: EditorNavigationBarTitleView.Model(
                icon: details?.objectIconImage,
                title: title
            )
        )
    }
    
}

// MARK: - Private extension

private extension EditorNavigationBarHelper {
    
    func configureNavigationItem(in vc: UIViewController) {
        vc.navigationItem.titleView = navigationBarTitleView
        
        vc.setupBackBarButtonItem(
            UIBarButtonItem(customView: backBarButtonItemView)
        )
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: settingsBarButtonItemView
        )
    }
    
    func updateBarButtonItemsBackground(alpha: CGFloat) {
        [backBarButtonItemView, settingsBarButtonItemView].forEach {
            guard !$0.backgroundAlpha.isEqual(to: alpha) else { return }
            
            $0.backgroundAlpha = alpha
        }
    }
    
    func updateNavigationBarAppearanceBasedOnContentOffset(_ newOffset: CGFloat) {
        let startAppearingOffset = objectHeaderHeight - 50
        let endAppearingOffset = objectHeaderHeight

        let navigationBarHeight = fakeNavigationBarBackgroundView.bounds.height
        
        let yFullOffset = newOffset + navigationBarHeight

        let alpha: CGFloat? = {
            if yFullOffset < startAppearingOffset {
                return 0
            } else if yFullOffset > endAppearingOffset {
                return 1
            } else if yFullOffset > startAppearingOffset, yFullOffset < endAppearingOffset {
                let currentDiff = yFullOffset - startAppearingOffset
                let max = endAppearingOffset - startAppearingOffset
                return currentDiff / max
            }
            
            return nil
        }()
        
        guard let alpha = alpha else {
            return
        }
        
        let barButtonItemsBackgroundAlpha: CGFloat = {
            guard isObjectHeaderWithCover else { return 0.0 }
            
            switch alpha {
            case 0.0:
                return isObjectHeaderWithCover ? 1.0 : 0.0
            default:
                return 1.0 - alpha
            }
        }()

        navigationBarTitleView.setAlphaForSubviews(alpha)
        updateBarButtonItemsBackground(alpha: barButtonItemsBackgroundAlpha)
        fakeNavigationBarBackgroundView.alpha = alpha
    }
    
}

// MARK: - ObjectHeader

private extension ObjectHeader {
    
    var isWithCover: Bool {
        switch self {
        case .iconOnly:
            return false
        case .coverOnly:
            return true
        case .iconAndCover:
            return true
        case .empty:
            return false
        }
    }
    
    var height: CGFloat {
        switch self {
        case .iconOnly:
            return ObjectHeaderView.Constants.filledHeaderHeight
        case .coverOnly:
            return ObjectHeaderView.Constants.filledHeaderHeight
        case .iconAndCover:
            return ObjectHeaderView.Constants.filledHeaderHeight
        case .empty:
            return ObjectHeaderView.Constants.emptyHeaderHeight
        }
    }
    
}
