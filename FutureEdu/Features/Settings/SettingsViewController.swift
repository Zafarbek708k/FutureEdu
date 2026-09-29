//
//  SettingsViewController.swift
//  FutureEdu
//

import UIKit

final class SettingsViewController: UIViewController {

    private enum Section: Int, CaseIterable {
        case appearance = 0
        case language = 1
        case about = 2
    }

    private let store: SettingsStore
    private let cellId = "SettingsCell"
    // comment for git 

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    init(store: SettingsStore? = nil) {
        self.store = store ?? SettingsStore.shared
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.store = SettingsStore.shared
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("settings.title")
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(tableView)
    }

    // Frame layout: the table fills the whole screen. It adds its own insets
    // for the navigation bar and tab bar (contentInsetAdjustmentBehavior).
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .appearance: return AppTheme.allCases.count
        case .language: return AppLanguage.allCases.count
        case .about: return 1
        case .none: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .appearance: return L10n.tr("settings.section.appearance")
        case .language: return L10n.tr("settings.section.language")
        case .about: return L10n.tr("settings.section.about")
        case .none: return nil
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        Section(rawValue: section) == .language ? L10n.tr("settings.language.footer") : nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.accessoryType = .none
        cell.selectionStyle = .default

        switch Section(rawValue: indexPath.section) {
        case .appearance:
            let theme = AppTheme.allCases[indexPath.row]
            var content = UIListContentConfiguration.cell()
            content.text = L10n.tr(theme.titleKey)
            content.image = UIImage(systemName: theme.iconName)
            content.imageProperties.tintColor = .systemIndigo
            cell.contentConfiguration = content
            cell.accessoryType = theme == store.theme ? .checkmark : .none

        case .language:
            let language = AppLanguage.allCases[indexPath.row]
            var content = UIListContentConfiguration.cell()
            content.text = "\(language.flag)  \(language.nativeName)"
            cell.contentConfiguration = content
            cell.accessoryType = language == store.language ? .checkmark : .none

        case .about:
            var content = UIListContentConfiguration.valueCell()
            content.text = L10n.tr("settings.version")
            content.secondaryText = appVersion
            cell.contentConfiguration = content
            cell.selectionStyle = .none

        case .none:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Section(rawValue: indexPath.section) {
        case .appearance:
            store.theme = AppTheme.allCases[indexPath.row]
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        case .language:
            // SceneDelegate rebuilds the UI in the new language.
            store.language = AppLanguage.allCases[indexPath.row]
        case .about, .none:
            break
        }
    }
}
