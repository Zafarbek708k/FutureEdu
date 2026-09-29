//
//  UIKit+Helpers.swift
//  FutureEdu
//

import UIKit

extension UIFont {
    /// Dynamic Type font for `style` with bold weight.
    static func preferredBold(_ style: UIFont.TextStyle) -> UIFont {
        let base = UIFont.preferredFont(forTextStyle: style)
        guard let descriptor = base.fontDescriptor.withSymbolicTraits(.traitBold) else { return base }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

/// Small capsule label, used for status / version badges.
final class BadgeLabel: UILabel {
    private let insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)

    init(text: String, color: UIColor) {
        super.init(frame: .zero)
        self.text = text
        textColor = color
        backgroundColor = color.withAlphaComponent(0.15)
        font = .preferredBold(.caption1)
        adjustsFontForContentSizeCategory = true
        layer.cornerRadius = 10
        layer.masksToBounds = true
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}

/// Rounded square with an SF Symbol, used as project icons.
final class IconTileView: UIView {
    init(systemName: String, tint: UIColor, size: CGFloat = 64, pointSize: CGFloat = 28) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = tint.withAlphaComponent(0.15)
        layer.cornerRadius = size * 0.25
        layer.cornerCurve = .continuous

        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
        let imageView = UIImageView(image: UIImage(systemName: systemName, withConfiguration: config))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = tint
        imageView.contentMode = .center
        addSubview(imageView)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
