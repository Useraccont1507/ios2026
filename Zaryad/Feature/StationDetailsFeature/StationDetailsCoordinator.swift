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

    init(
        navigating: UINavigationController,
        container: DIContainer,
        station: ChargingStation,
        mapProvider: PMapProvider?
    ) {
        self.assembly = StationDetailsAssembly(container: container)
        self.station = station
        self.mapProvider = mapProvider
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
