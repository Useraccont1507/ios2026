//
//  FavoritesCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class FavoritesCoordinator: Coordinator {
    private let container: DIContainer
    private let assembly: FavoritesAssembly
    private weak var mapProvider: PMapProvider?

    init(navigating: UINavigationController, container: DIContainer, mapProvider: PMapProvider?) {
        self.container = container
        self.assembly = FavoritesAssembly(container: container)
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
            container: container,
            station: station,
            mapProvider: mapProvider
        )
        .storeAndStart(in: self)
    }
}
