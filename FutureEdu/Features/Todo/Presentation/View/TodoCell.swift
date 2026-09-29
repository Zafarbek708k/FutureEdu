//
//  TodoCell.swift
//  FutureEdu
//
//  Frame-based cell:
//   • layoutSubviews()  – positions the subviews
//   • sizeThatFits(_:)  – tells the table how tall the cell must be
//
//   ┌──────────────────────────────────────────────┐
//   │ 8 [ ○ 44×44 ] 6  Title (multi-line)       16 │
//   │                  Date                        │
//   └──────────────────────────────────────────────┘
//

import UIKit

final class TodoCell: UITableViewCell {
    static let reuseIdentifier = "TodoCell"

    var onCheckboxTapped: (() -> Void)?

    // MARK: - Layout constants
    private enum Metrics {
        static let checkboxLeading: CGFloat = 8
        static let checkboxSize: CGFloat = 44          // Apple HIG minimum tap target
        static let checkboxToText: CGFloat = 6
        static let textTrailing: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let titleToDate: CGFloat = 4

        /// x where the text column starts.
        static var textX: CGFloat { checkboxLeading + checkboxSize + checkboxToText }
    }

    // MARK: - Subviews
    private let checkboxButton = UIButton(type: .system)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        return label
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

    // MARK: - Init
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)

        checkboxButton.addTarget(self, action: #selector(checkboxAction), for: .touchUpInside)

        // The whole row is one accessibility element; activating it toggles
        // the task via tableView(_:didSelectRowAt:).
        isAccessibilityElement = true
    }

    // MARK: - Layout (frames)

    /// Width available for the title/date column in a cell that is `cellWidth` wide.
    private static func textWidth(forCellWidth cellWidth: CGFloat) -> CGFloat {
        max(0, cellWidth - Metrics.textX - Metrics.textTrailing)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let textWidth = Self.textWidth(forCellWidth: bounds.width)

        // Checkbox: fixed size, vertically centered.
        checkboxButton.frame = CGRect(
            x: Metrics.checkboxLeading,
            y: (bounds.height - Metrics.checkboxSize) / 2,
            width: Metrics.checkboxSize,
            height: Metrics.checkboxSize
        )

        // Title + date as one block, vertically centered.
        let titleHeight = titleLabel.fittingHeight(forWidth: textWidth)
        let dateHeight = dateLabel.fittingHeight(forWidth: textWidth)
        let blockHeight = titleHeight + Metrics.titleToDate + dateHeight
        let blockY = (bounds.height - blockHeight) / 2

        titleLabel.frame = CGRect(x: Metrics.textX, y: blockY, width: textWidth, height: titleHeight)
        dateLabel.frame = CGRect(x: Metrics.textX, y: titleLabel.frame.maxY + Metrics.titleToDate,
                                 width: textWidth, height: dateHeight)
    }

    /// Height of the cell for a given width (content must already be configured).
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textWidth = Self.textWidth(forCellWidth: size.width)
        let textHeight = titleLabel.fittingHeight(forWidth: textWidth)
            + Metrics.titleToDate
            + dateLabel.fittingHeight(forWidth: textWidth)

        let contentHeight = max(textHeight, Metrics.checkboxSize)
        return CGSize(width: size.width, height: ceil(contentHeight + Metrics.verticalPadding * 2))
    }

    /// UITableView (rowHeight = automaticDimension) asks the cell for its size
    /// through this method. We have no constraints, so answer with sizeThatFits.
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        sizeThatFits(CGSize(width: targetSize.width, height: .greatestFiniteMagnitude))
    }

    // MARK: - Actions
    @objc private func checkboxAction() {
        onCheckboxTapped?()
    }

    // MARK: - Configure
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

        setNeedsLayout()
    }
}
