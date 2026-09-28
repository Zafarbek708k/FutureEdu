//
//  HomeViewController.swift
//  FutureEdu
//

import UIKit

// Root of the Home tab: a list of the projects this app bundles together.
// Today there's only the Todo app; more entries can be added to `projects`
// and routed to their own root view controller in didSelectRowAt.
final class HomeViewController: UIViewController {

    private let projects: [ProjectItem] = [
        ProjectItem(
            icon: "checklist",
            title: NSLocalizedString("project_todo_title", comment: "Todo app project name"),
            subtitle: NSLocalizedString("project_todo_subtitle", comment: "Todo app project description")
        )
    ]

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ProjectCell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = NSLocalizedString("home_title", comment: "Home screen title")
        view.backgroundColor = .systemGroupedBackground

        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath)
        let project = projects[indexPath.row]

        var config = UIListContentConfiguration.subtitleCell()
        config.text = project.title
        config.secondaryText = project.subtitle
        config.image = UIImage(systemName: project.icon)
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(TodoViewController(), animated: true)
    }
}
