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
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
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

    private static let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
    private static let checkedImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfig)
    private static let uncheckedImage = UIImage(systemName: "circle", withConfiguration: symbolConfig)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onCheckboxTapped = nil
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .secondarySystemGroupedBackground

        contentView.addSubview(checkboxButton)
        contentView.addSubview(textStackView)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(dateLabel)

        checkboxButton.addTarget(self, action: #selector(checkboxAction), for: .touchUpInside)

        // The whole row is one accessibility element; activating it toggles
        // the task via tableView(_:didSelectRowAt:).
        isAccessibilityElement = true

        NSLayoutConstraint.activate([
            // 44x44 pt tap target (Apple HIG minimum); the icon itself stays 22 pt.
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 44),
            checkboxButton.heightAnchor.constraint(equalToConstant: 44),
            checkboxButton.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 4),
            checkboxButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4),

            textStackView.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 6),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    @objc private func checkboxAction() {
        onCheckboxTapped?()
    }

    func configure(with item: TodoItem) {
        let locale = Localizer.shared.locale
        if Self.dateFormatter.locale != locale {
            Self.dateFormatter.locale = locale
        }
        let dateText = Self.dateFormatter.string(from: item.createdAt)
        dateLabel.text = dateText

        if item.isCompleted {
            checkboxButton.setImage(Self.checkedImage, for: .normal)
            checkboxButton.tintColor = .systemGreen

            let fullRange = NSRange(location: 0, length: (item.title as NSString).length)
            let attributed = NSMutableAttributedString(string: item.title)
            attributed.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: fullRange)
            attributed.addAttribute(.foregroundColor, value: UIColor.tertiaryLabel, range: fullRange)
            titleLabel.attributedText = attributed
        } else {
            checkboxButton.setImage(Self.uncheckedImage, for: .normal)
            checkboxButton.tintColor = .systemGray3

            titleLabel.attributedText = nil
            titleLabel.text = item.title
            titleLabel.textColor = .label
        }

        accessibilityLabel = item.title
        accessibilityValue = L10n.tr(item.isCompleted ? "todo.a11y.completed" : "todo.a11y.notCompleted")
        accessibilityHint = dateText
        accessibilityTraits = item.isCompleted ? [.button, .selected] : [.button]
    }
}
