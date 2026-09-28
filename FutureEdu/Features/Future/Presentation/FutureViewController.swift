//
//  FutureViewController.swift
//  FutureEdu
//

import UIKit

// Root of the Future tab: a read-only roadmap of planned features.
final class FutureViewController: UIViewController {

    private let items: [FutureTaskItem] = [
        FutureTaskItem(
            title: NSLocalizedString("future_cloud_sync_title", comment: "Planned feature: cloud sync"),
            subtitle: NSLocalizedString("future_cloud_sync_subtitle", comment: "Cloud sync description")
        ),
        FutureTaskItem(
            title: NSLocalizedString("future_reminders_title", comment: "Planned feature: reminders"),
            subtitle: NSLocalizedString("future_reminders_subtitle", comment: "Reminders description")
        ),
        FutureTaskItem(
            title: NSLocalizedString("future_widgets_title", comment: "Planned feature: home screen widgets"),
            subtitle: NSLocalizedString("future_widgets_subtitle", comment: "Widgets description")
        ),
        FutureTaskItem(
            title: NSLocalizedString("future_live_language_title", comment: "Planned feature: instant language switching"),
            subtitle: NSLocalizedString("future_live_language_subtitle", comment: "Instant language switching description")
        )
    ]

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "FutureTaskCell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = NSLocalizedString("future_title", comment: "Future screen title")
        view.backgroundColor = .systemGroupedBackground

        tableView.dataSource = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension FutureViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FutureTaskCell", for: indexPath)
        let item = items[indexPath.row]

        var config = UIListContentConfiguration.subtitleCell()
        config.text = item.title
        config.secondaryText = item.subtitle
        config.image = UIImage(systemName: "hourglass")
        cell.contentConfiguration = config
        cell.selectionStyle = .none

        return cell
    }
}
