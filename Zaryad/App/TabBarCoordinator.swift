//
//  TabBarCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    private let tabBarController = UITabBarController()
    // TODO: - real repositories (лаб 4)
    private let stationsRepository: PStationsRepository = MockStationsRepository()
    private let favoritesRepository: PFavoritesRepository = MockFavoritesRepository()

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
        case .map:
            MapCoordinator(
                navigating: navigation,
                stationsRepository: stationsRepository,
                favoritesRepository: favoritesRepository
            )
            .storeAndStart(in: self)
        case .favorites:
            FavoritesCoordinator(
                navigating: navigation,
                favoritesRepository: favoritesRepository,
                mapProvider: self
            )
            .storeAndStart(in: self)
        }
        return navigation
    }

    private func select(_ tab: Tab) {
        guard let index = Tab.allCases.firstIndex(of: tab) else { return }
        tabBarController.selectedIndex = index
    }
}

// MARK: - PMapProvider
extension TabBarCoordinator: PMapProvider {
    func showStation(id: Int, at coordinate: Coordinate) {
        guard let mapProvider = childCoordinators.first(where: { $0 is PMapProvider }) as? PMapProvider else { return }
        select(.map)
        mapProvider.showStation(id: id, at: coordinate)
    }
}

extension TabBarCoordinator {
    enum Tab: CaseIterable {
        case map
        case favorites

        var tabBarItem: UITabBarItem {
            switch self {
            case .map:
                UITabBarItem(
                    title: "Карта",
                    image: UIImage(systemName: "map"),
                    selectedImage: UIImage(systemName: "map.fill")
                )
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
