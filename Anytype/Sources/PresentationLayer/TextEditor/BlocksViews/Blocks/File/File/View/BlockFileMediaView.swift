import UIKit
import Combine

struct BlockFileMediaData {
    var size: String
    var name: String
    var typeIcon: UIImage?
}

class BlockFileMediaView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        self.addSubview(imageView)
        self.addSubview(titleView)
        self.addSubview(sizeView)
    
        layoutUsing.stack {
            $0.hStack(alignedTo: .center,
                $0.hGap(fixed: 3),
                imageView,
                $0.hGap(fixed: 7),
                titleView,
                $0.hGap(fixed: 10),
                sizeView,
                $0.hGap()
            )
        }
    }
    
    func handleNewData(data: BlockFileMediaData) {
        titleView.text = data.name
        imageView.image = data.typeIcon
        sizeView.text = data.size
    }
    
    let imageView: UIImageView  = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()
    
    let titleView: UILabel = {
        let view = UILabel()
        view.font = .bodyFont
        view.textColor = .textColor
        return view
    }()
    
    let sizeView: UILabel = {
        let view = UILabel()
        view.font = .captionFont
        view.textColor = .secondaryTextColor
        return view
    }()
}
