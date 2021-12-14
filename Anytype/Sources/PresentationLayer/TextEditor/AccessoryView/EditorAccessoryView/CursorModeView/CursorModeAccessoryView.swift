import UIKit
import Amplitude
import BlocksModels

class CursorModeAccessoryView: UIView {
    private let viewModel: CursorModeAccessoryViewModel

    // MARK: - Lifecycle

    init(viewModel: CursorModeAccessoryViewModel) {
        self.viewModel = viewModel

        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        setupViews()
    }

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .backgroundPrimary
        addSubview(stackView)
        stackView.edgesToSuperview()
    }
    
    // MARK: - Public methods
    func setDelegate(_ delegate: CursorModeAccessoryViewDelegate) {
        viewModel.delegate = delegate
    }
    
    func update(info: BlockInformation, textView: UITextView) {
        viewModel.textView = textView
        viewModel.info = info
        
        updateMenuItems(info: info)
    }

    // MARK: - Private methods
    private func updateMenuItems(info: BlockInformation) {
        let items: [Item]
        if info.content.type == .text(.title) {
            items = [.style]
        } else {
            items = [.slash, .style, .actions, .mention]
        }
        
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        items.forEach { item in
            addBarButtonItem(image: item.image) { [weak self] _ in
                // Analytics
                Amplitude.instance().logEvent(item.analyticsEvent)
                UISelectionFeedbackGenerator().selectionChanged()

                self?.viewModel.handle(item.action)
            }
        }

        addBarButtonItem(title: "Done".localized) { [weak self] _ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.buttonHideKeyboard)
            UISelectionFeedbackGenerator().selectionChanged()

            self?.viewModel.handle(.keyboardDismiss)
        }
    }

    /// Add bar item with title and image.
    /// - Parameters:
    ///   - title: Title. If nil a title is not displayed.
    ///   - image: Image. If nil a image is not displayed.
    ///   - action: Action performed on touch
    private func addBarButtonItem(
        title: String? = nil, image: UIImage? = nil, action: @escaping UIActionHandler
    ) {
        let primaryAction = UIAction(handler: action)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.pureAmber, for: .normal)
        button.addAction(primaryAction, for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }
    
    // MARK: - Views
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually

        return stackView
    }()
    
    // MARK: - Unavailable
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("Not been implemented") }
}
