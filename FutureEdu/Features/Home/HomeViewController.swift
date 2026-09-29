//
//  HomeViewController.swift
//  FutureEdu
//

import UIKit

final class HomeViewController: UIViewController {

    private let projects = HomeProject.all
    private let cellId = "ProjectCell"

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("home.title")
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh live subtitles (e.g. active task count) when coming back.
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        projects.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        L10n.tr("home.section.projects")
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        L10n.tr("home.footer.more")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let project = projects[indexPath.row]

        var content = UIListContentConfiguration.subtitleCell()
        content.text = project.title
        content.textProperties.font = .preferredBold(.headline)
        content.secondaryText = project.subtitle()
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: project.iconName)
        content.imageProperties.tintColor = project.tint
        content.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        content.imageToTextPadding = 16
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = projects[indexPath.row].makeViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
