//
//  FutureDetailViewController.swift
//  FutureEdu
//
//  Generic detail page for an upcoming project or a doc entry.
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

    private let content: Content

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    init(content: Content) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20)
        ])

        buildContent()
    }

    // MARK: - Building

    private func buildContent() {
        // Header: icon + title
        let icon = IconTileView(systemName: content.iconName, tint: content.tint)
        let titleLabel = makeLabel(content.title, font: .preferredBold(.title1), color: .label)

        let header = UIStackView(arrangedSubviews: [icon, titleLabel])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 16
        stackView.addArrangedSubview(header)

        // Badges
        if !content.badges.isEmpty {
            let badgeViews: [UIView] = content.badges.map { BadgeLabel(text: $0.text, color: $0.color) }
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            let badgesRow = UIStackView(arrangedSubviews: badgeViews + [spacer])
            badgesRow.axis = .horizontal
            badgesRow.spacing = 8
            stackView.addArrangedSubview(badgesRow)
        }

        // Body
        stackView.addArrangedSubview(makeCard(with: [
            makeLabel(content.body, font: .preferredFont(forTextStyle: .body), color: .label)
        ]))

        // Optional list (e.g. planned features)
        if let listTitle = content.listTitle, !content.listItems.isEmpty {
            let sectionTitle = makeLabel(listTitle.uppercased(), font: .preferredFont(forTextStyle: .footnote), color: .secondaryLabel)
            stackView.setCustomSpacing(24, after: stackView.arrangedSubviews.last ?? sectionTitle)
            stackView.addArrangedSubview(sectionTitle)
            stackView.setCustomSpacing(8, after: sectionTitle)
            stackView.addArrangedSubview(makeCard(with: content.listItems.map(makeListRow)))
        }
    }

    private func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    private func makeListRow(_ text: String) -> UIView {
        let config = UIImage.SymbolConfiguration(textStyle: .body, scale: .medium)
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill", withConfiguration: config))
        imageView.tintColor = content.tint
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [
            imageView,
            makeLabel(text, font: .preferredFont(forTextStyle: .body), color: .label)
        ])
        row.axis = .horizontal
        row.alignment = .firstBaseline
        row.spacing = 12
        return row
    }

    private func makeCard(with views: [UIView]) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.layer.cornerCurve = .continuous

        let inner = UIStackView(arrangedSubviews: views)
        inner.translatesAutoresizingMaskIntoConstraints = false
        inner.axis = .vertical
        inner.spacing = 12
        card.addSubview(inner)

        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])
        return card
    }
}
