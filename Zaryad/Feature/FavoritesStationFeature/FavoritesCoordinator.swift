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
    private weak var mapProvider: PMapProvider?

    init(navigating: UINavigationController, favoritesRepository: PFavoritesRepository, mapProvider: PMapProvider?) {
        self.assembly = FavoritesAssembly(repo: favoritesRepository)
        self.favoritesRepository = favoritesRepository
        self.mapProvider = mapProvider
        super.init(navigating: navigating)
    }

    override func start() {
        naviagateToList()
    }

    private func naviagateToList() {
        let vc = assembly.makeFavoritesList { [weak self] station in
            self?.navigateToStationDetails(station)
        }
        navigating.setViewControllers([vc], animated: false)
    }

    private func navigateToStationDetails(_ station: ChargingStation) {
        StationDetailsCoordinator(
            navigating: navigating,
            favoritesRepository: favoritesRepository,
            station: station,
            mapProvider: mapProvider
        )
        .storeAndStart(in: self)
    }
}
