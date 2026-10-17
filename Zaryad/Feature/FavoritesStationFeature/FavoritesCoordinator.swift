//
//  FavoritesCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class FavoritesCoordinator: Coordinator {
    private let assembly: FavoritesAssembly
    private let favoritesRepository: PFavoritesRepository
    private let authRepository: PAuthRepository
    private weak var favoritesInput: PFavoritesModuleInput?
    private weak var mapProvider: PMapProvider?
    private weak var profileProvider: PProfileProvider?

    init(
        navigating: UINavigationController,
        favoritesRepository: PFavoritesRepository,
        authRepository: PAuthRepository,
        mapProvider: PMapProvider?,
        profileProvider: PProfileProvider?
    ) {
        self.assembly = FavoritesAssembly(repo: favoritesRepository)
        self.favoritesRepository = favoritesRepository
        self.authRepository = authRepository
        self.mapProvider = mapProvider
        self.profileProvider = profileProvider
        super.init(navigating: navigating)
    }

    override func start() {
        naviagateToList()
    }

    func clearFavorites() {
        navigating.popToRootViewController(animated: false)
        favoritesInput?.clear()
    }

    private func naviagateToList() {
        let module = assembly.makeFavoritesList { [weak self] station in
            self?.navigateToStationDetails(station)
        }
        favoritesInput = module.input
        navigating.setViewControllers([module.vc], animated: false)
    }

    private func navigateToStationDetails(_ station: ChargingStation) {
        StationDetailsCoordinator(
            navigating: navigating,
            favoritesRepository: favoritesRepository,
            authRepository: authRepository,
            station: station,
            mapProvider: mapProvider,
            profileProvider: profileProvider
        )
        .onComplete { coordinator, isCancelled in
            if isCancelled { coordinator.free() }
        }
        .storeAndStart(in: self)
    }
}
