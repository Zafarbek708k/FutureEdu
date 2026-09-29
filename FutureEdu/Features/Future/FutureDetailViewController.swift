//
//  FutureDetailViewController.swift
//  FutureEdu
//
//  Generic detail page for an upcoming project or a doc entry.
//  Frame-based layout inside a UIScrollView:
//
//   ┌ 20 ───────────────────────────────── 20 ┐
//   │ [icon 64]  Title                        │
//   │ (badge) (badge)                         │
//   │ ┌ bodyCard ───────────────────────────┐ │
//   │ │ body text                           │ │
//   │ └─────────────────────────────────────┘ │
//   │ LIST TITLE                              │
//   │ ┌ listCard ───────────────────────────┐ │
//   │ │ ✓ item                              │ │
//   │ │ ✓ item                              │ │
//   │ └─────────────────────────────────────┘ │
//   └─────────────────────────────────────────┘
//

import UIKit

final class FutureDetailViewController: UIViewController {

    struct Badge {
        let text: String
        let color: UIColor
    }

    struct Content {
        let title: String
        let iconName: String
        let tint: UIColor
        let badges: [Badge]
        let body: String
        let listTitle: String?
        let listItems: [String]
    }

    // MARK: - Layout constants
    private enum Metrics {
        static let margin: CGFloat = 20         // screen edges
        static let cardPadding: CGFloat = 16    // inside cards
        static let iconSize: CGFloat = 64
        static let iconToTitle: CGFloat = 16
        static let sectionSpacing: CGFloat = 16
        static let badgeSpacing: CGFloat = 8
        static let rowIconSize: CGFloat = 22
        static let rowIconToText: CGFloat = 12
        static let rowSpacing: CGFloat = 12
    }

    private let content: Content

    // MARK: - Subviews
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        return scroll
    }()

    private lazy var iconView = IconTileView(systemName: content.iconName, tint: content.tint)
    private lazy var titleLabel = makeLabel(content.title, font: .preferredBold(.title1), color: .label)
    private lazy var badgeLabels = content.badges.map { BadgeLabel(text: $0.text, color: $0.color) }

    private let bodyCard = FutureDetailViewController.makeCard()
    private lazy var bodyLabel = makeLabel(content.body, font: .preferredFont(forTextStyle: .body), color: .label)

    private lazy var listTitleLabel = makeLabel(
        (content.listTitle ?? "").uppercased(),
        font: .preferredFont(forTextStyle: .footnote),
        color: .secondaryLabel
    )
    private let listCard = FutureDetailViewController.makeCard()
    /// One (checkmark, text) pair per list item.
    private var listRows: [(icon: UIImageView, label: UILabel)] = []

    private var hasList: Bool {
        content.listTitle != nil && !content.listItems.isEmpty
    }

    // MARK: - Init
    init(content: Content) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(scrollView)

        // Add everything once; positions are calculated in viewDidLayoutSubviews.
        scrollView.addSubview(iconView)
        scrollView.addSubview(titleLabel)
        badgeLabels.forEach { scrollView.addSubview($0) }

        scrollView.addSubview(bodyCard)
        bodyCard.addSubview(bodyLabel)

        if hasList {
            scrollView.addSubview(listTitleLabel)
            scrollView.addSubview(listCard)
            listRows = content.listItems.map { text in
                let icon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
                icon.tintColor = content.tint
                icon.contentMode = .scaleAspectFit
                let label = makeLabel(text, font: .preferredFont(forTextStyle: .body), color: .label)
                listCard.addSubview(icon)
                listCard.addSubview(label)
                return (icon, label)
            }
        }
    }

    // MARK: - Layout (frames)

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds

        let safe = view.safeAreaInsets
        let x = safe.left + Metrics.margin
        let width = view.bounds.width - safe.left - safe.right - Metrics.margin * 2

        // `y` is a cursor that moves down as we place each element.
        var y: CGFloat = Metrics.margin

        // 1. Header: icon on the left, title vertically centered next to it.
        iconView.frame.origin = CGPoint(x: x, y: y)
        let titleX = x + Metrics.iconSize + Metrics.iconToTitle
        let titleWidth = width - Metrics.iconSize - Metrics.iconToTitle
        let titleHeight = titleLabel.fittingHeight(forWidth: titleWidth)
        let headerHeight = max(Metrics.iconSize, titleHeight)
        titleLabel.frame = CGRect(x: titleX, y: y + (headerHeight - titleHeight) / 2,
                                  width: titleWidth, height: titleHeight)
        y += headerHeight + Metrics.sectionSpacing

        // 2. Badges: placed left to right, wrap to a new line if they don't fit.
        if !badgeLabels.isEmpty {
            var badgeX = x
            var rowHeight: CGFloat = 0
            for badge in badgeLabels {
                let size = badge.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
                if badgeX > x, badgeX + size.width > x + width {   // no room -> next line
                    badgeX = x
                    y += rowHeight + Metrics.badgeSpacing
                }
                badge.frame = CGRect(x: badgeX, y: y, width: size.width, height: size.height)
                badgeX += size.width + Metrics.badgeSpacing
                rowHeight = max(rowHeight, size.height)
            }
            y += rowHeight + Metrics.sectionSpacing
        }

        // 3. Body card: label inside with padding; card height follows the text.
        let innerWidth = width - Metrics.cardPadding * 2
        let bodyHeight = bodyLabel.fittingHeight(forWidth: innerWidth)
        bodyLabel.frame = CGRect(x: Metrics.cardPadding, y: Metrics.cardPadding,
                                 width: innerWidth, height: bodyHeight)
        bodyCard.frame = CGRect(x: x, y: y, width: width, height: bodyHeight + Metrics.cardPadding * 2)
        y = bodyCard.frame.maxY

        // 4. Optional list: section title + card with one row per item.
        if hasList {
            y += 24
            let listTitleHeight = listTitleLabel.fittingHeight(forWidth: width - Metrics.cardPadding)
            listTitleLabel.frame = CGRect(x: x + Metrics.cardPadding, y: y,
                                          width: width - Metrics.cardPadding, height: listTitleHeight)
            y = listTitleLabel.frame.maxY + 8

            let textX = Metrics.cardPadding + Metrics.rowIconSize + Metrics.rowIconToText
            let textWidth = width - textX - Metrics.cardPadding
            var rowY = Metrics.cardPadding   // cursor inside the card

            for row in listRows {
                let textHeight = row.label.fittingHeight(forWidth: textWidth)
                row.label.frame = CGRect(x: textX, y: rowY, width: textWidth, height: textHeight)

                // Align the icon with the first line of text.
                let firstLineHeight = row.label.font.lineHeight
                row.icon.frame = CGRect(x: Metrics.cardPadding,
                                        y: rowY + (firstLineHeight - Metrics.rowIconSize) / 2,
                                        width: Metrics.rowIconSize, height: Metrics.rowIconSize)

                rowY += textHeight + Metrics.rowSpacing
            }
            let cardHeight = rowY - Metrics.rowSpacing + Metrics.cardPadding
            listCard.frame = CGRect(x: x, y: y, width: width, height: cardHeight)
            y = listCard.frame.maxY
        }

        // 5. Tell the scroll view how tall the content is, so it can scroll.
        scrollView.contentSize = CGSize(width: view.bounds.width, height: y + 32)
    }

    // MARK: - Factories

    private func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    private static func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.layer.cornerCurve = .continuous
        return card
    }
}
