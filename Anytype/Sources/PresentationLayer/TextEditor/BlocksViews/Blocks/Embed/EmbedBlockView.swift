import UIKit
import AnytypeCore
import WebKit
//import HCVimeoVideoExtractor
import AVKit

final class EmbedBlockView: UIView, BlockContentView {

    private let titleLabel: AnytypeLabel = {
        let title = AnytypeLabel(style: .subheading)
        title.numberOfLines = 1
        title.textColor = .Text.primary
        return title
    }()
    
    private let webView = WKWebViewVideoView()
//    private let playerUIView = LoopingPlayerUIView(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
//    private let playerUIView = LoopingPlayerUIView(url: URL(string: "https://skyfire.vimeocdn.com/1703105000-0xe27bbcfb1c57b016ea1d852f5e94d960020ca734/1d3cfe8b-2570-4c2a-bf61-41d754a0ed04/sep/video/0018aa38,0349cc79,45cb40e3,6d5a9faf,72ff789b,d462e47a,ed9506c1/audio/e50fa7df/subtitles/124138683-English%20%28United%20Kingdom%29-en-GB/master.m3u8?external-subs=1&query_string_ranges=1&subcache=1&subtoken=5c3431098aa1971e985b4437c0b9209bd7f99db0728e19b7f34cd9c1f737b82b")!)
//    private let playerUIView = PlayerUIView()
    
    private let videoPlayerView = VideoPlayerView()
    private let playerViewController = AVPlayerViewController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: EmbedBlockConfiguration) {
        let html = "<iframe width=\"100%\" height=\"315\" src=\"https://www.youtube.com/embed/Z1GlRPRvYdY?si=9m5W781_GLpSb6ub\" title=\"YouTube video player\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" allowfullscreen></iframe>"
//        "https://www.youtube.com/embed/Z1GlRPRvYdY?si=9m5W781_GLpSb6ub"
        webView.play(with: html, url: "")
//        titleLabel.setText(configuration.content.url)
//        youtubeVideoView.play(with: configuration.content.url)
//        "https://www.youtube.com/watch?v=ZafJLuDGzY8"
//        "https://www.youtube.com/embed/ZafJLuDGzY8"
    
//        youtubeVideoView.play(with: "https://vimeo.com/894052647")
        
//        playerUIView.setup(with: "https://www.youtube.com/embed/ZafJLuDGzY8")
        
//        playerUIView.setup(with: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
//        let url = URL(string: "https://vimeo.com/894052647")!
//        HCVimeoVideoExtractor.fetchVideoURLFrom(url: url, completion: { [weak self] ( video:HCVimeoVideo?, error:Error?) -> Void in
//            if let err = error {
//                print("Error = \(err.localizedDescription)")
//                return
//            }
//            
//            guard let vid = video else {
//                print("Invalid video object")
//                return
//            }
//            
//            print("Title = \(vid.title), url = \(vid.videoURL), thumbnail = \(vid.thumbnailURL)")
//                
//            if let videoURL = vid.videoURL[.quality1080p] {
//                let player = AVPlayer(url: videoURL)
//                let playerController = AVPlayerViewController()
//                playerController.player = player
//                self.present(playerController, animated: true) {
//                    player.play()
//                }
//                DispatchQueue.main.async {
//                    self?.playerUIView.setup(with: videoURL)
//                }
                
//                let player = AVPlayer(url: videoURL)
//                self?.videoPlayerView.player = player
//                player.play()
                
//                let player = AVPlayer(url: videoURL)
//                self?.playerViewController.player = player
//                DispatchQueue.main.async {
//                    player.play()
//                }
//            }
//        })
        
    }

    private func setup() {
//        addSubview(titleLabel) {
//            $0.pinToSuperview(insets: Layout.contentViewInsets)
//        }
        addSubview(webView) {
            $0.pinToSuperview(insets: Layout.contentViewInsets)
            $0.height.equal(to: 300)
        }
        
//        addSubview(playerUIView) {
//            $0.pinToSuperview()
//            $0.height.equal(to: 300)
//            $0.width.equal(to: 300)
//        }
        
//        addSubview(videoPlayerView) {
//            $0.pinToSuperview()
//            $0.height.equal(to: 300)
//            $0.width.equal(to: 300)
//        }
        
//        addSubview(playerViewController.view) {
//            $0.pinToSuperview()
//            $0.height.equal(to: 300)
//            $0.width.equal(to: 300)
//        }
    }
}

private extension EmbedBlockView {
    enum Layout {
        static let contentViewInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
}

class WKWebViewVideoView: UIView {
    
    private lazy var webConfig: WKWebViewConfiguration = {
        $0.allowsInlineMediaPlayback = true
        return $0
    }(WKWebViewConfiguration())
    
    private lazy var webView: WKWebView = {
        $0.scrollView.isScrollEnabled = false
        return $0
    }(WKWebView(frame: .zero, configuration: webConfig))
    
    init() {
        super.init(frame: .zero)
        configureViews()
        backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        addSubview(webView) {
            $0.pinToSuperview()
        }
    }
    
    func play(with string: String, url: String) {
        webView.loadHTMLString(string, baseURL: URL(string: url))
//        guard let url = URL(string: url) else { return }
//        webView.load(.init(url: url))
    }
}

final class PlayerUIView: UIView, SceneStateListener {
    
    private let playerLayer = AVPlayerLayer()
//    private var playerLooper: AVPlayerLooper?
    private let player = AVQueuePlayer()
    private let sceneStateNotifier = ServiceLocator.shared.sceneStateNotifier()
    
    init() {
        super.init(frame: .zero)
        
        sceneStateNotifier.addListener(self)
//        setup(with: url)
        backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with url: String) {
        guard let url = URL(string: url) else { return }
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
//        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        player.play()
    }
    
    func setup(with url: URL) {
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
//        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        player.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
//        playerLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
    }
    
    // MARK: - SceneStateListener
    
    func willEnterForeground() {
        player.play()
    }
    
    func didEnterBackground() {}
}

class VideoPlayerView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }

        set {
            playerLayer.player = newValue
        }
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

