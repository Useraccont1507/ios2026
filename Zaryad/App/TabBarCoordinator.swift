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
        case .map:
            MapCoordinator(navigating: navigation).storeAndStart(in: self)
        case .favorites:
            FavoritesCoordinator(navigating: navigation)
                .onComplete { [weak self] _, completion in
                    switch completion {
                    case .showOnMap(let station):
                        self?.showOnMap(station)
                    }
                }
                .storeAndStart(in: self)
        }
        return navigation
    }

    private func select(_ tab: Tab) {
        guard let index = Tab.allCases.firstIndex(of: tab) else { return }
        tabBarController.selectedIndex = index
    }

    private func showOnMap(_ station: ChargingStation) {
        guard let coordinate = station.coordinate,
              let mapCoordinator = childCoordinators.first(where: { $0 is MapCoordinator }) as? MapCoordinator
        else { return }
        select(.map)
        mapCoordinator.showStation(id: station.id, at: coordinate)
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
