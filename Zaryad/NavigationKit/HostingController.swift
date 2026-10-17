//
//  HostingController.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import SwiftUI

/// `UIHostingController`, що повідомляє, коли його прибрали зі стеку (back / pop),
/// щоб координатор міг себе звільнити.
final class HostingController<Content: View>: UIHostingController<Content> {
    var onRemoveFromParent: (() -> Void)?

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            onRemoveFromParent?()
        }
    }
}
