//
//  TodoViewController.swift
//  FutureEdu
//

import UIKit

final class TodoViewController: UIViewController {

    private let viewModel: TodoViewModel

    // MARK: - UI Components
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            NSLocalizedString("filter_all", comment: "Show all tasks"),
            NSLocalizedString("filter_active", comment: "Show only active tasks"),
            NSLocalizedString("filter_completed", comment: "Show only completed tasks")
        ])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
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

    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        let imageView = UIImageView(image: UIImage(systemName: "checklist", withConfiguration: iconConfig))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("empty_state_title", comment: "Shown when there are no tasks")
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = NSLocalizedString("empty_state_subtitle", comment: "Hint on how to add a task")
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.textAlignment = .center

        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        return view
    }()

    // MARK: - Initializer
    init(viewModel: TodoViewModel = TodoViewModel()) {
        self.viewModel = viewModel
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
        title = NSLocalizedString("my_tasks_title", comment: "Main screen title")
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chart.pie"),
            style: .plain,
            target: self,
            action: #selector(didTapStats)
        )

        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        tableView.dataSource = self
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
        viewModel.onTodosUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }

    private func updateUI() {
        tableView.reloadData()
        let isEmpty = viewModel.numberOfTodos == 0
        emptyStateView.isHidden = !isEmpty
    }

    // MARK: - Actions
    @objc private func filterChanged() {
        if let filter = TodoFilter(rawValue: segmentedControl.selectedSegmentIndex) {
            viewModel.currentFilter = filter
        }
    }

    @objc private func didTapAddButton() {
        let alert = UIAlertController(
            title: NSLocalizedString("new_task_title", comment: "New task alert title"),
            message: NSLocalizedString("new_task_message", comment: "New task alert message"),
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("new_task_placeholder", comment: "New task text field placeholder")
            textField.autocapitalizationType = .sentences
        }

        let addAction = UIAlertAction(title: NSLocalizedString("add_action", comment: "Confirm adding a task"), style: .default) { [weak self, weak alert] _ in
            guard let text = alert?.textFields?.first?.text else { return }
            self?.viewModel.addTodo(title: text)
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel_action", comment: "Cancel adding a task"), style: .cancel)

        alert.addAction(addAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    @objc private func didTapStats() {
        // Modal presentation: a self-contained screen wrapped in its own
        // navigation bar, shown over the current one instead of pushed onto it.
        let statsVC = StatsViewController(stats: viewModel.stats)
        let nav = UINavigationController(rootViewController: statsVC)
        present(nav, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension TodoViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTodos
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell,
              let item = viewModel.item(at: indexPath.row) else {
            return UITableViewCell()
        }

        cell.configure(with: item)
        cell.onCheckboxTapped = { [weak self] in
            self?.viewModel.toggleTodo(at: indexPath.row)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = viewModel.item(at: indexPath.row) else { return }

        // Push navigation: the detail screen is pushed onto the same
        // navigation stack, with a back button added automatically.
        let detailVC = TodoDetailViewController(todo: item) { [weak self] updatedTodo in
            self?.viewModel.updateTodo(id: updatedTodo.id, title: updatedTodo.title, isCompleted: updatedTodo.isCompleted)
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("delete_action", comment: "Swipe-to-delete action title")) { [weak self] (_, _, completionHandler) in
            self?.viewModel.deleteTodo(at: indexPath.row)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
