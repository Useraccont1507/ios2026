//
//  MapCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class MapCoordinator: Coordinator {
    private let assembly: MapAssembly
    private let favoritesRepository: PFavoritesRepository
    private weak var mapInput: PMapModuleInput?

    init(
        navigating: UINavigationController,
        stationsRepository: PStationsRepository,
        favoritesRepository: PFavoritesRepository
    ) {
        self.assembly = MapAssembly(stationsRepo: stationsRepository)
        self.favoritesRepository = favoritesRepository
        super.init(navigating: navigating)
    }

    override func start() {
        navigateToMap()
    }

    private func navigateToMap() {
        let module = assembly.makeMap { [weak self] station in
            self?.navigateToStationDetails(station)
        }
        mapInput = module.input
        navigating.setViewControllers([module.vc], animated: false)
    }

    private func navigateToStationDetails(_ station: ChargingStation) {
        StationDetailsCoordinator(
            navigating: navigating,
            favoritesRepository: favoritesRepository,
            station: station,
            mapProvider: self
        )
        .storeAndStart(in: self)
    }
}

// MARK: - PMapProvider
extension MapCoordinator: PMapProvider {
    func showStation(id: Int, at coordinate: Coordinate) {
        navigating.popToRootViewController(animated: true)
        mapInput?.showStation(id: id, at: coordinate)
    }
}
