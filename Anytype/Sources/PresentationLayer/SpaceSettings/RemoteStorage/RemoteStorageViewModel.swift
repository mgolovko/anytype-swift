import Foundation
import Services
import UIKit
import Combine
import AnytypeCore

@MainActor
final class RemoteStorageViewModel: ObservableObject {
    
    private enum Constants {
        
        static let warningPercent = 0.9
        static let mailTo = "storage@anytype.io"
    }
    
    private let accountManager: AccountManagerProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let fileLimitsStorage: FileLimitsStorageProtocol
    private let documentProvider: DocumentsProviderProtocol
    private weak var output: RemoteStorageModuleOutput?
    private var subscriptions = [AnyCancellable]()
    private let subSpaceId = "RemoteStorageViewModel-Space-\(UUID())"
    
    private let byteCountFormatter = ByteCountFormatter.fileFormatter
    
    private var nodeUsage: NodeUsageInfo?
    
    @Published var spaceInstruction: String = ""
    @Published var spaceUsed: String = ""
    @Published var contentLoaded: Bool = false
    @Published var showGetMoreSpaceButton: Bool = false
    @Published var segmentItems: [SegmentItem] = []
    
    init(
        accountManager: AccountManagerProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        fileLimitsStorage: FileLimitsStorageProtocol,
        documentProvider: DocumentsProviderProtocol,
        output: RemoteStorageModuleOutput?
    ) {
        self.accountManager = accountManager
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.subscriptionService = subscriptionService
        self.fileLimitsStorage = fileLimitsStorage
        self.documentProvider = documentProvider
        self.output = output
        setupPlaceholderState()
        Task {
            await setupSubscription()
        }
    }
        
    func onTapManageFiles() {
        output?.onManageFilesSelected()
    }
    
    func onAppear() {
        // TODO: Add analytics
    }
    
    func onTapGetMoreSpace() {
        guard let nodeUsage else { return }
        AnytypeAnalytics.instance().logGetMoreSpace()
        Task { @MainActor in
            let profileDocument = documentProvider.document(
                objectId: activeWorkspaceStorage.workspaceInfo.profileObjectID,
                forPreview: true
            )
            try await profileDocument.openForPreview()
            let limit = byteCountFormatter.string(fromByteCount: nodeUsage.node.bytesLimit)
            let mailLink = MailUrl(
                to: Constants.mailTo,
                subject: Loc.FileStorage.Space.Mail.subject(accountManager.account.id),
                body: Loc.FileStorage.Space.Mail.body(limit, accountManager.account.id, profileDocument.details?.name ?? "")
            )
            guard let mailLinkUrl = mailLink.url else { return }
            output?.onLinkOpen(url: mailLinkUrl)
        }
    }
    
    // MARK: - Private
    
    private func setupSubscription() async {
        fileLimitsStorage.nodeUsage
            .receiveOnMain()
            .sink { [weak self] nodeUsage in
                // Some times middleware responds with big delay.
                // If middle upload a lot of files, read operation blocked.
                // May be fixed in feature.
                // Slack discussion https://anytypeio.slack.com/archives/C04QVG8V15K/p1684399017487419?thread_ts=1684244283.014759&cid=C04QVG8V15K
                self?.contentLoaded = true
                self?.nodeUsage = nodeUsage
                self?.updateView(nodeUsage: nodeUsage)
            }
            .store(in: &subscriptions)
    }
    
    private func setupPlaceholderState() {
        updateView(nodeUsage: .zero)
    }
    
    private func updateView(nodeUsage: NodeUsageInfo) {
        let bytesUsed = nodeUsage.node.bytesUsage
        let bytesLimit = nodeUsage.node.bytesLimit
        
        let used = byteCountFormatter.string(fromByteCount: bytesUsed)
        let limit = byteCountFormatter.string(fromByteCount: bytesLimit)
        
        spaceInstruction = Loc.FileStorage.Space.instruction(limit)
        spaceUsed = Loc.FileStorage.Space.used(used, limit)
        let percentUsage = Double(bytesUsed) / Double(bytesLimit)
        showGetMoreSpaceButton = percentUsage >= Constants.warningPercent
        
        let spaceId = activeWorkspaceStorage.workspaceInfo.accountSpaceId
        
        var segmentItems = [SegmentItem]()
        
        if let spaceView = activeWorkspaceStorage.spaceView(),
            let spaceUsage = nodeUsage.spaces.first(where: { $0.spaceID == spaceId }) {
            segmentItems.append(
                SegmentItem(
                    color: .System.amber125,
                    value: Double(spaceUsage.bytesUsage) / Double(bytesLimit),
                    legend: Loc.FileStorage.LimitLegend.current(spaceView.name, byteCountFormatter.string(fromByteCount: spaceUsage.bytesUsage))
                )
            )
        }
    
        let otherUsageBytes = nodeUsage.spaces.filter { $0.spaceID != spaceId }.reduce(Int64(0), { $0 + $1.bytesUsage })
        
        segmentItems.append(
            SegmentItem(
                color: .System.amber50,
                value: Double(otherUsageBytes) / Double(bytesLimit),
                legend: Loc.FileStorage.LimitLegend.other(byteCountFormatter.string(fromByteCount: otherUsageBytes))
            )
        )
        
        segmentItems.append(
            SegmentItem(
                color: .Stroke.tertiary,
                value: Double(nodeUsage.node.bytesLeft) / Double(bytesLimit),
                legend: Loc.FileStorage.LimitLegend.free(byteCountFormatter.string(fromByteCount: nodeUsage.node.bytesLeft))
            )
        )
        
        self.segmentItems = segmentItems
    }
}
