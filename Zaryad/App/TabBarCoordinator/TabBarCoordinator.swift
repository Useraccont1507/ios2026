//
//  TabBarCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    private let tabBarController = UITabBarController()
    private let stationsRepository: PStationsRepository = StationsRepository(
        requestManager: RequestManager(baseURL: OCMConfig.baseURL)
    )
    private let locationService: PLocationService = LocationService()
    private let authRepository: PAuthRepository
    private let favoritesRepository: PFavoritesRepository

    override init(navigating: UINavigationController) {
        let service = FirebaseService()
        let authRepository = FirebaseAuthRepository(service: service)
        self.authRepository = authRepository
        self.favoritesRepository = FirebaseFavoritesRepository(
            service: service,
            authRepo: authRepository,
            requestManager: RequestManager(baseURL: FirestoreEndpoint.baseURL(projectID: service.projectID))
        )
        super.init(navigating: navigating)
    }

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
                locationService: locationService,
                favoritesRepository: favoritesRepository,
                authRepository: authRepository,
                profileProvider: self
            )
            .storeAndStart(in: self)
        case .favorites:
            FavoritesCoordinator(
                navigating: navigation,
                favoritesRepository: favoritesRepository,
                authRepository: authRepository,
                mapProvider: self,
                profileProvider: self
            )
            .storeAndStart(in: self)
        case .profile:
            let coordinator = ProfileCoordinator(
                navigating: navigation,
                authRepository: authRepository,
                favoritesRepository: favoritesRepository
            )
            coordinator.delegate = self
            coordinator.storeAndStart(in: self)
        }
        return navigation
    }

    private func select(_ tab: Tab) {
        guard let index = Tab.allCases.firstIndex(of: tab) else { return }
        tabBarController.selectedIndex = index
    }

    private func child<T: Coordinator>(_ type: T.Type) -> T? {
        childCoordinators.first { $0 is T } as? T
    }
}

// MARK: - TabBarCoordinator + Map
extension TabBarCoordinator: PMapProvider {
    func showStation(id: Int, at coordinate: Coordinate) {
        guard let mapProvider = childCoordinators.first(where: { $0 is PMapProvider }) as? PMapProvider else { return }
        select(.map)
        mapProvider.showStation(id: id, at: coordinate)
    }
}

// MARK: - TabBarCoordinator + Profile
extension TabBarCoordinator: PProfileCoordinatorDelegate, PProfileProvider {
    func profileCoordinatorDidSignOut(_ coordinator: ProfileCoordinator) {
        child(FavoritesCoordinator.self)?.clearFavorites()
    }
    func showProfile() {
        guard let profileProvider = childCoordinators.first(where: { $0 is PProfileProvider }) as? PProfileProvider else { return }
        select(.profile)
        profileProvider.showProfile()
    }
}
