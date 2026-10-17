//
//  AppCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class AppCoordinator: Coordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
        let rootNavigation = UINavigationController()
        rootNavigation.setNavigationBarHidden(true, animated: false)
        super.init(navigating: rootNavigation)
    }

    override func start() {
        window.rootViewController = navigating
        window.makeKeyAndVisible()
        showMainFlow()
    }

    private func showMainFlow() {
        childCoordinators.removeAll()
        TabBarCoordinator(navigating: navigating).storeAndStart(in: self)
    }
}
