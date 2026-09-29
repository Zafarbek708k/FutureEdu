//
//  HomeViewController.swift
//  FutureEdu
//

import UIKit

final class HomeViewController: UIViewController {

    private let projects = HomeProject.all
    private let cellId = "ProjectCell"
    private var hasAppeared = false
    private var needsReload = false

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
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
    }

    // Frame layout: the table fills the whole screen. It adds its own insets
    // for the navigation bar and tab bar (contentInsetAdjustmentBehavior).
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // First appearance already shows fresh data from viewDidLoad.
        guard hasAppeared else { return }

        // Refresh live subtitles (e.g. active task count) when coming back.
        // In viewWillAppear the table may not be in the window yet, and reloading
        // it then logs "UITableView was told to layout its visible cells … without
        // being in the view hierarchy". So reload alongside the transition (the view
        // is already in the transition container), or right after it appears.
        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.tableView.reloadData()
            })
        } else if tableView.window != nil {
            tableView.reloadData()
        } else {
            needsReload = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasAppeared = true
        if needsReload {
            needsReload = false
            tableView.reloadData()
        }
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
