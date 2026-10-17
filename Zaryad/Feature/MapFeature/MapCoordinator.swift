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
    private let authRepository: PAuthRepository
    private weak var mapInput: PMapModuleInput?
    private weak var profileProvider: PProfileProvider?

    init(
        navigating: UINavigationController,
        stationsRepository: PStationsRepository,
        favoritesRepository: PFavoritesRepository,
        authRepository: PAuthRepository,
        profileProvider: PProfileProvider?
    ) {
        self.assembly = MapAssembly(stationsRepo: stationsRepository)
        self.favoritesRepository = favoritesRepository
        self.authRepository = authRepository
        self.profileProvider = profileProvider
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
            authRepository: authRepository,
            station: station,
            mapProvider: self,
            profileProvider: profileProvider
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
