//
//  UIKit+Helpers.swift
//  FutureEdu
//
//  Small reusable views, laid out with frames (no Auto Layout).
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

extension UILabel {
    /// Height this (multi-line) label needs when it is `width` points wide.
    func fittingHeight(forWidth width: CGFloat) -> CGFloat {
        let size = sizeThatFits(CGSize(width: max(0, width), height: .greatestFiniteMagnitude))
        return ceil(size.height)
    }
}

/// Small capsule label, used for status / version badges.
/// Call `sizeToFit()` (or `sizeThatFits`) to get its size including padding.
final class BadgeLabel: UILabel {
    private let insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)

    init(text: String, color: UIColor) {
        super.init(frame: .zero)
        self.text = text
        textColor = color
        backgroundColor = color.withAlphaComponent(0.15)
        font = .preferredBold(.caption1)
        adjustsFontForContentSizeCategory = true
        textAlignment = .center
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // Text is drawn inside the padding.
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    // Size of the text + padding on every side.
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textSize = super.sizeThatFits(size)
        return CGSize(width: ceil(textSize.width) + insets.left + insets.right,
                      height: ceil(textSize.height) + insets.top + insets.bottom)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2   // capsule shape
    }
}

/// Rounded square with an SF Symbol in the middle, used as project icons.
final class IconTileView: UIView {
    private let imageView = UIImageView()

    init(systemName: String, tint: UIColor, size: CGFloat = 64, pointSize: CGFloat = 28) {
        // The tile knows its own size; the parent only sets its origin.
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        backgroundColor = tint.withAlphaComponent(0.15)
        layer.cornerRadius = size * 0.25
        layer.cornerCurve = .continuous

        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
        imageView.image = UIImage(systemName: systemName, withConfiguration: config)
        imageView.tintColor = tint
        imageView.contentMode = .center
        addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds   // fills the tile; .center keeps the symbol centered
    }
}
