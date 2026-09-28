//
//  SettingsViewController.swift
//  FutureEdu
//

import UIKit

// Root of the Settings tab. Two independent choices, each backed by its own
// manager: ThemeManager applies instantly (overrideUserInterfaceStyle),
// LocalizationManager takes effect on the next launch (AppleLanguages is
// only read by Foundation at process start), so picking a language shows a
// restart notice.
final class SettingsViewController: UIViewController {

    private enum Section: Int, CaseIterable {
        case theme
        case language
    }

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = NSLocalizedString("settings_title", comment: "Settings screen title")
        view.backgroundColor = .systemGroupedBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func presentLanguageRestartNotice() {
        let alert = UIAlertController(
            title: NSLocalizedString("language_restart_title", comment: "Alert title asking for a restart"),
            message: NSLocalizedString("language_restart_message", comment: "Alert message asking for a restart"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok_action", comment: "Acknowledge the restart notice"), style: .default))
        present(alert, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .theme: return NSLocalizedString("settings_theme_section", comment: "Theme section header")
        case .language: return NSLocalizedString("language_section", comment: "Language section header")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .theme: return AppTheme.allCases.count
        case .language: return AppLanguage.allCases.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)

        switch Section(rawValue: indexPath.section)! {
        case .theme:
            let theme = AppTheme.allCases[indexPath.row]
            cell.textLabel?.text = theme.localizedTitle
            cell.accessoryType = theme == ThemeManager.shared.currentTheme ? .checkmark : .none
        case .language:
            let language = AppLanguage.allCases[indexPath.row]
            cell.textLabel?.text = language.localizedTitle
            cell.accessoryType = language == LocalizationManager.shared.currentLanguage ? .checkmark : .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Section(rawValue: indexPath.section)! {
        case .theme:
            ThemeManager.shared.currentTheme = AppTheme.allCases[indexPath.row]
        case .language:
            let newLanguage = AppLanguage.allCases[indexPath.row]
            guard newLanguage != LocalizationManager.shared.currentLanguage else { return }
            LocalizationManager.shared.currentLanguage = newLanguage
            presentLanguageRestartNotice()
        }

        tableView.reloadData()
    }
}
