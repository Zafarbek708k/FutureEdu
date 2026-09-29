//
//  EmptyStateView.swift
//  FutureEdu
//
//  Icon + title + subtitle, centered vertically. Frame-based layout.
//

import UIKit

final class EmptyStateView: UIView {

    private let iconSize: CGFloat = 60
    private let sidePadding: CGFloat = 20

    private let imageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        let imageView = UIImageView(image: UIImage(systemName: "checklist", withConfiguration: config))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        setNeedsLayout()   // text changed -> heights may change
    }

    private func setupViews() {
        isUserInteractionEnabled = false
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }

    // Called by UIKit whenever this view's size changes (or after setNeedsLayout).
    override func layoutSubviews() {
        super.layoutSubviews()

        let textWidth = bounds.width - sidePadding * 2
        let titleHeight = titleLabel.fittingHeight(forWidth: textWidth)
        let subtitleHeight = subtitleLabel.fittingHeight(forWidth: textWidth)

        // Total height of the block, so we can center it vertically.
        let blockHeight = iconSize + 12 + titleHeight + 6 + subtitleHeight
        var y = (bounds.height - blockHeight) / 2

        imageView.frame = CGRect(x: (bounds.width - iconSize) / 2, y: y, width: iconSize, height: iconSize)
        y = imageView.frame.maxY + 12

        titleLabel.frame = CGRect(x: sidePadding, y: y, width: textWidth, height: titleHeight)
        y = titleLabel.frame.maxY + 6

        subtitleLabel.frame = CGRect(x: sidePadding, y: y, width: textWidth, height: subtitleHeight)
    }
}
