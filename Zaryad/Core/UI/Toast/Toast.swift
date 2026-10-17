//
//  Toast.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

protocol PToastPresenter {
    func show(_ message: String)
}

/// Тост помилки поверх усього вікна застосунку; сам зникає через `showDuration`.
final class Toast: PToastPresenter {
    static let shared = Toast()

    private let showDuration: Duration = .seconds(3)
    private weak var toastView: ToastView?
    private var hideTask: Task<Void, Never>?

    private init() {}

    func show(_ message: String) {
        guard let container = Self.keyWindow else { return }
        hideTask?.cancel()
        toastView?.removeFromSuperview()

        let toast = ToastView(message: message)
        container.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 8),
            toast.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            toast.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        toastView = toast

        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: -20)
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
            toast.transform = .identity
        }

        hideTask = Task { [weak self, showDuration] in
            try? await Task.sleep(for: showDuration)
            guard !Task.isCancelled else { return }
            self?.hide(toast)
        }
    }

    private func hide(_ toast: ToastView) {
        UIView.animate(withDuration: 0.2) {
            toast.alpha = 0
            toast.transform = CGAffineTransform(translationX: 0, y: -20)
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }

    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .keyWindow
    }
}
