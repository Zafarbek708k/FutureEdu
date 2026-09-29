//
//  FutureViewController.swift
//  FutureEdu
//

import UIKit

final class FutureViewController: UIViewController {

    private enum Section: Int, CaseIterable {
        case upcoming = 0
        case docs = 1
    }

    private let projects = FutureProject.all
    private let docs = DocEntry.all
    private let cellId = "FutureCell"

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("future.title")
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(tableView)
    }

    // Frame layout: the table fills the whole screen. It adds its own insets
    // for the navigation bar and tab bar (contentInsetAdjustmentBehavior).
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FutureViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .upcoming: return projects.count
        case .docs: return docs.count
        case .none: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .upcoming: return L10n.tr("future.section.upcoming")
        case .docs: return L10n.tr("future.section.docs")
        case .none: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        content.imageToTextPadding = 16
        content.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        content.secondaryTextProperties.color = .secondaryLabel
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        switch Section(rawValue: indexPath.section) {
        case .upcoming:
            let project = projects[indexPath.row]
            content.text = project.title
            content.textProperties.font = .preferredBold(.headline)
            content.secondaryText = "v\(project.version) · \(L10n.tr(project.status.titleKey))"
            content.secondaryTextProperties.color = project.status.color
            content.image = UIImage(systemName: project.iconName)
            content.imageProperties.tintColor = project.tint
        case .docs:
            let doc = docs[indexPath.row]
            content.text = doc.title
            content.image = UIImage(systemName: doc.iconName)
            content.imageProperties.tintColor = doc.tint
        case .none:
            break
        }

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let content: FutureDetailViewController.Content
        switch Section(rawValue: indexPath.section) {
        case .upcoming:
            let project = projects[indexPath.row]
            content = .init(
                title: project.title,
                iconName: project.iconName,
                tint: project.tint,
                badges: [
                    .init(text: L10n.tr(project.status.titleKey), color: project.status.color),
                    .init(text: L10n.tr("future.detail.version", project.version), color: .secondaryLabel)
                ],
                body: project.summary,
                listTitle: L10n.tr("future.detail.features"),
                listItems: project.features
            )
        case .docs:
            let doc = docs[indexPath.row]
            content = .init(
                title: doc.title,
                iconName: doc.iconName,
                tint: doc.tint,
                badges: [],
                body: doc.body,
                listTitle: nil,
                listItems: []
            )
        case .none:
            return
        }

        navigationController?.pushViewController(FutureDetailViewController(content: content), animated: true)
    }
}
