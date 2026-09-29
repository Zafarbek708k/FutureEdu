//
//  TodoViewController.swift
//  FutureEdu
//

import UIKit

final class TodoViewController: UIViewController {

    /// Single-section table. `Int` is used as the section identifier because the
    /// target has default MainActor isolation and diffable identifiers must have a
    /// non-isolated `Hashable` conformance (`Int`, `UUID` qualify out of the box).
    private static let mainSection = 0

    private let viewModel: TodoViewModel
    private var hasAppliedInitialSnapshot = false

    // MARK: - UI Components
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            L10n.tr("todo.filter.all", 0),
            L10n.tr("todo.filter.active", 0),
            L10n.tr("todo.filter.done", 0)
        ])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = TodoFilter.all.rawValue
        return control
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 60
        return table
    }()

    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.isHidden = true
        return view
    }()

    private lazy var dataSource = makeDataSource()

    // MARK: - Initializer
    init(viewModel: TodoViewModel? = nil) {
        self.viewModel = viewModel ?? TodoViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = TodoViewModel()
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        updateUI()
    }

    // MARK: - Setup
    private func setupUI() {
        title = L10n.tr("todo.title")
        view.backgroundColor = .systemGroupedBackground

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        addButton.accessibilityLabel = L10n.tr("todo.add.a11y")
        navigationItem.rightBarButtonItem = addButton

        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        tableView.dataSource = dataSource
        tableView.delegate = self

        segmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupBindings() {
        // TodoViewModel is @MainActor, so callbacks already arrive on the main thread.
        viewModel.onTodosUpdated = { [weak self] in
            self?.updateUI()
        }
    }

    private func makeDataSource() -> UITableViewDiffableDataSource<Int, UUID> {
        UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, id in
            guard let self,
                  let item = self.viewModel.item(id: id),
                  let cell = tableView.dequeueReusableCell(
                    withIdentifier: TodoCell.reuseIdentifier, for: indexPath
                  ) as? TodoCell
            else {
                return UITableViewCell()
            }

            cell.configure(with: item)
            // Capture the stable id, never the indexPath.
            cell.onCheckboxTapped = { [weak self] in
                self?.viewModel.toggleTodo(id: id)
            }
            return cell
        }
    }

    // MARK: - Rendering
    private func updateUI() {
        let ids = viewModel.filteredTodos.map(\.id)
        let previousIds = Set(dataSource.snapshot().itemIdentifiers)

        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([Self.mainSection])
        snapshot.appendItems(ids)
        // Rows that stayed on screen may have changed content (e.g. toggled).
        snapshot.reconfigureItems(ids.filter(previousIds.contains))

        dataSource.apply(snapshot, animatingDifferences: hasAppliedInitialSnapshot)
        hasAppliedInitialSnapshot = true

        let isEmpty = ids.isEmpty
        emptyStateView.isHidden = !isEmpty
        if isEmpty {
            let state = viewModel.emptyState
            emptyStateView.configure(title: state.title, subtitle: state.subtitle)
        }

        updateSegmentTitles()
    }

    private func updateSegmentTitles() {
        segmentedControl.setTitle(L10n.tr("todo.filter.all", viewModel.allTodos.count), forSegmentAt: TodoFilter.all.rawValue)
        segmentedControl.setTitle(L10n.tr("todo.filter.active", viewModel.remainingCount), forSegmentAt: TodoFilter.active.rawValue)
        segmentedControl.setTitle(L10n.tr("todo.filter.done", viewModel.completedCount), forSegmentAt: TodoFilter.completed.rawValue)
    }

    // MARK: - Actions
    @objc private func filterChanged() {
        if let filter = TodoFilter(rawValue: segmentedControl.selectedSegmentIndex) {
            viewModel.currentFilter = filter
        }
    }

    @objc private func didTapAddButton() {
        let alert = UIAlertController(
            title: L10n.tr("todo.alert.title"),
            message: L10n.tr("todo.alert.message"),
            preferredStyle: .alert
        )

        let addAction = UIAlertAction(title: L10n.tr("todo.alert.add"), style: .default) { [weak self, weak alert] _ in
            guard let text = alert?.textFields?.first?.text else { return }
            self?.viewModel.addTodo(title: text)
        }
        addAction.isEnabled = false

        alert.addTextField { textField in
            textField.placeholder = L10n.tr("todo.alert.placeholder")
            textField.autocapitalizationType = .sentences
            textField.returnKeyType = .done
            // Enable "Add" only when the text is not blank.
            textField.addAction(UIAction { [weak addAction] action in
                let text = (action.sender as? UITextField)?.text ?? ""
                addAction?.isEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }, for: .editingChanged)
        }

        alert.addAction(UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel))
        alert.addAction(addAction)
        alert.preferredAction = addAction

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension TodoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let id = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.toggleTodo(id: id)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let id = dataSource.itemIdentifier(for: indexPath) else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: L10n.tr("common.delete")) { [weak self] _, _, completionHandler in
            self?.viewModel.deleteTodo(id: id)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
