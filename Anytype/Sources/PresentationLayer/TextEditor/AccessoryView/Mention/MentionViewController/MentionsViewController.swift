import UIKit
import Combine
import Services
import SwiftUI

final class MentionsViewController: UITableViewController {
    let viewModel: MentionsViewModel
    var dismissAction: (() -> Void)?
    
    private lazy var dataSource = makeDataSource()
    private var subsriptions = [AnyCancellable]()
    
    init(viewModel: MentionsViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
        
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$mentions.sink { [weak self] mentions in
            self?.display(mentions)
        }.store(in: &subsriptions)
        
        viewModel.dismissSubject.sink { [weak self] _ in
            self?.dismiss()
        }.store(in: &subsriptions)
    }
    
    private func setup() {
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseId)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .createNewObject:
            viewModel.didSelectCreateNewMention()
        case let .mention(mention):
            viewModel.didSelectMention(mention)
        case .header:
            break
        }
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<MentionSection, MentionDisplayData> {
        UITableViewDiffableDataSource<MentionSection, MentionDisplayData>(tableView: tableView) { [weak self] tableView, indexPath, displayData -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath)
            switch displayData {
            case let .createNewObject(objectName):
                cell.separatorInset = Constants.separatorInsets
                cell.contentConfiguration = self?.createNewObjectContentConfiguration(objectName: objectName)
            case let .mention(mention):
                cell.separatorInset = Constants.separatorInsets
                cell.contentConfiguration = self?.confguration(for: mention)
            case let .header(title):
                cell.separatorInset = Constants.headerSeparatorInsets
                cell.contentConfiguration = self?.header(title: title)
            }
            return cell
        }
    }
    
    private func confguration(for mention: MentionObject) -> any UIContentConfiguration {
        EditorSearchCellConfiguration(
            cellData: EditorSearchCellData(
                title: mention.name,
                subtitle: mention.type?.name ?? Loc.Mention.Subtitle.placeholder,
                icon: mention.objectIcon,
                expandedIcon: false
            )
        )
    }
    
    private func createNewObjectContentConfiguration(objectName: String) -> any UIContentConfiguration {
        var configuration = UIListContentConfiguration.cell()

        if objectName.isEmpty {
            configuration.text = Loc.createNewObject
        } else {
            let mutableAttributedString = NSMutableAttributedString(
                string: Loc.createObject,
                attributes: [.font: UIFont.uxTitle2Regular, .foregroundColor: UIColor.Text.primary]
            )
            let nameAttributedString = NSAttributedString(
                string: objectName,
                attributes: [.font: UIFont.uxTitle2Medium, .foregroundColor: UIColor.Text.primary]
            )

            mutableAttributedString.append(.init(string: " \""))
            mutableAttributedString.append(nameAttributedString)
            mutableAttributedString.append(.init(string: "\""))

            configuration.attributedText = mutableAttributedString
        }

        configuration.textProperties.font = .uxTitle2Regular
        configuration.textProperties.color = .Text.secondary
        
        configuration.image = UIImage(asset: .createNewObject)
        configuration.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        configuration.imageProperties.maximumSize = CGSize(width: 40, height: 40)
        configuration.imageToTextPadding = Constants.createNewObjectImagePadding
        return configuration
    }
    
    private func header(title: String) -> any UIContentConfiguration {
        UIHostingConfiguration {
            SectionHeaderView(title: title)
        }
        .minSize(height: 0)
        .margins(.vertical, 0)
    }
    
    // MARK: - Constants
    private enum Constants {
        static let cellReuseId = NSStringFromClass(UITableViewCell.self)
        static let separatorInsets = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 20)
        static let headerSeparatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        static let cellHeight: CGFloat = 56
        static let createNewObjectImagePadding: CGFloat = 12
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MentionsViewController {
    
    private func display(_ list: [MentionDisplayData]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<MentionSection, MentionDisplayData>()
            snapshot.appendSections(MentionSection.allCases)
            snapshot.appendItems(list, toSection: .first)
            snapshot.appendItems([.createNewObject(objectName: viewModel.searchString)], toSection: .second)
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func update(mention: MentionDisplayData) {
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.reloadItems([mention])
            self.dataSource.apply(snapshot)
        }
    }
    
    func dismiss() {
        dismissAction?()
    }
}
