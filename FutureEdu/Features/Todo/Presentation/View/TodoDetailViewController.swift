//
//  TodoDetailViewController.swift
//  FutureEdu
//

import UIKit

// Pushed onto the navigation stack (`pushViewController`) from TodoViewController.
// Shows the two common directions data travels between screens:
// - forward: the caller injects the `TodoItem` through the initializer
// - backward: this screen reports the edited item through the `onSave` closure,
//   instead of the caller polling this screen or using a delegate protocol
final class TodoDetailViewController: UIViewController {

    private var todo: TodoItem
    private let onSave: (TodoItem) -> Void

    private let titleField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 17)
        return field
    }()

    private let createdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private let completedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Completed"
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()

    private let completedSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    init(todo: TodoItem, onSave: @escaping (TodoItem) -> Void) {
        self.todo = todo
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateFields()
    }

    private func setupUI() {
        title = "Task Details"
        view.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(didTapSave)
        )

        let toggleRow = UIStackView(arrangedSubviews: [completedLabel, completedSwitch])
        toggleRow.translatesAutoresizingMaskIntoConstraints = false
        toggleRow.axis = .horizontal
        toggleRow.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [titleField, createdLabel, toggleRow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func populateFields() {
        titleField.text = todo.title
        completedSwitch.isOn = todo.isCompleted
        createdLabel.text = "Created \(Self.dateFormatter.string(from: todo.createdAt))"
    }

    @objc private func didTapSave() {
        let newTitle = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !newTitle.isEmpty else { return }

        todo.title = newTitle
        todo.isCompleted = completedSwitch.isOn
        onSave(todo)

        navigationController?.popViewController(animated: true)
    }
}
