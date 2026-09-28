//
//  StatsViewController.swift
//  FutureEdu
//

import UIKit

// Presented modally (`present(_:animated:)`) rather than pushed, to contrast
// with the push navigation used by TodoDetailViewController. Data flows one
// way only: a TodoStats value is computed once and injected at creation
// time; this screen never reports anything back to its presenter.
final class StatsViewController: UIViewController {

    private let stats: TodoStats

    init(stats: TodoStats) {
        self.stats = stats
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = NSLocalizedString("overview_title", comment: "Stats screen title")
        view.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapDone)
        )

        let stack = UIStackView(arrangedSubviews: [
            makeRow(title: NSLocalizedString("stats_total", comment: "Total tasks count label"), value: stats.total),
            makeRow(title: NSLocalizedString("stats_active", comment: "Active tasks count label"), value: stats.active),
            makeRow(title: NSLocalizedString("stats_completed", comment: "Completed tasks count label"), value: stats.completed)
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func makeRow(title: String, value: Int) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17)

        let valueLabel = UILabel()
        valueLabel.text = "\(value)"
        valueLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        valueLabel.textColor = .secondaryLabel

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        return row
    }

    @objc private func didTapDone() {
        dismiss(animated: true)
    }
}
