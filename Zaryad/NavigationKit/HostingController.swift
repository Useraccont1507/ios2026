//
//  HostingController.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import SwiftUI

final class HostingController<Content: View>: UIHostingController<Content> {
    var onRemoveFromParent: (() -> Void)?

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            onRemoveFromParent?()
        }
    }
}
