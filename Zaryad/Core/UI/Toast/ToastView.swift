//
//  ToastView.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class ToastView: UIView {
    init(message: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        setupShadow()
        setupContent(message: message)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    private func setupContent(message: String) {
        let background = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        background.translatesAutoresizingMaskIntoConstraints = false
        background.layer.cornerRadius = 20
        background.layer.cornerCurve = .continuous
        background.layer.borderWidth = 1
        background.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.25).cgColor
        background.clipsToBounds = true

        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        icon.tintColor = .systemRed
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = message
        label.font = UIFont.preferredFont(forTextStyle: .subheadline).withWeight(.medium)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 12
        stack.alignment = .center

        addSubview(background)
        background.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: background.contentView.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: background.contentView.bottomAnchor, constant: -14),
            stack.leadingAnchor.constraint(equalTo: background.contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: background.contentView.trailingAnchor, constant: -16)
        ])

        isAccessibilityElement = true
        accessibilityLabel = message
    }
}

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: descriptor, size: 0)
    }
}

#if DEBUG
#Preview {
    ToastView(message: "Немає з'єднання з інтернетом")
}
#endif
