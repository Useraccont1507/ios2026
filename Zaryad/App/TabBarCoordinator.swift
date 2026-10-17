//
//  TabBarCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    private let tabBarController = UITabBarController()

    override func start() {
        let controllers = Tab.allCases.map(makeFlow)
        tabBarController.setViewControllers(controllers, animated: false)
        navigating.setViewControllers([tabBarController], animated: false)
    }

    private func makeFlow(for tab: Tab) -> UINavigationController {
        let navigation = UINavigationController()
        navigation.navigationBar.prefersLargeTitles = true
        navigation.tabBarItem = tab.tabBarItem
        switch tab {
        case .favorites:
            FavoritesCoordinator(navigating: navigation).storeAndStart(in: self)
        }
        return navigation
    }
}

extension TabBarCoordinator {
    enum Tab: CaseIterable {
        case favorites

        var tabBarItem: UITabBarItem {
            switch self {
            case .favorites:
                UITabBarItem(
                    title: "Обране",
                    image: UIImage(systemName: "star"),
                    selectedImage: UIImage(systemName: "star.fill")
                )
            }
        }
    }
}
