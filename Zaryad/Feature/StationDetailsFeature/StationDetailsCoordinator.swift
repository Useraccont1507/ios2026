//
//  StationDetailsCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class StationDetailsCoordinator: Coordinator {
    private let assembly: StationDetailsAssembly
    private let station: ChargingStation
    private weak var mapProvider: PMapProvider?
    private weak var profileProvider: PProfileProvider?

    init(
        navigating: UINavigationController,
        favoritesRepository: PFavoritesRepository,
        authRepository: PAuthRepository,
        station: ChargingStation,
        mapProvider: PMapProvider?,
        profileProvider: PProfileProvider?
    ) {
        self.assembly = StationDetailsAssembly(favoritesRepo: favoritesRepository, authRepo: authRepository)
        self.station = station
        self.mapProvider = mapProvider
        self.profileProvider = profileProvider
        super.init(navigating: navigating)
    }

    override func start() {
        navigateToDetails()
    }

    private func navigateToDetails() {
        let vc = assembly.makeStationDetails(
            station: station,
            onShowOnMap: { [weak self] station in
                self?.showOnMap(station)
            },
            onAuthRequired: { [weak self] in
                self?.profileProvider?.showProfile()
            },
            onClose: { [weak self] in
                self?.free()
            }
        )
        navigating.pushViewController(vc, animated: true)
    }

    private func showOnMap(_ station: ChargingStation) {
        guard let coordinate = station.coordinate else { return }
        mapProvider?.showStation(id: station.id, at: coordinate)
    }
}
