//
//  TodoCell.swift
//  FutureEdu
//

import UIKit

final class TodoCell: UITableViewCell {
    static let reuseIdentifier = "TodoCell"

    var onCheckboxTapped: (() -> Void)?

    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .secondarySystemGroupedBackground

        contentView.addSubview(checkboxButton)
        contentView.addSubview(textStackView)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(dateLabel)

        checkboxButton.addTarget(self, action: #selector(checkboxAction), for: .touchUpInside)

        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 28),
            checkboxButton.heightAnchor.constraint(equalToConstant: 28),

            textStackView.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 14),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    @objc private func checkboxAction() {
        onCheckboxTapped?()
    }

    func configure(with item: TodoItem) {
        dateLabel.text = Self.dateFormatter.string(from: item.createdAt)

        if item.isCompleted {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
            let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfig)
            checkboxButton.setImage(image, for: .normal)
            checkboxButton.tintColor = .systemGreen

            let attributeString = NSMutableAttributedString(string: item.title)
            attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
            attributeString.addAttribute(.foregroundColor, value: UIColor.tertiaryLabel, range: NSRange(location: 0, length: attributeString.length))
            titleLabel.attributedText = attributeString
        } else {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
            let image = UIImage(systemName: "circle", withConfiguration: symbolConfig)
            checkboxButton.setImage(image, for: .normal)
            checkboxButton.tintColor = .systemGray3

            titleLabel.attributedText = nil
            titleLabel.text = item.title
            titleLabel.textColor = .label
        }
    }
}
