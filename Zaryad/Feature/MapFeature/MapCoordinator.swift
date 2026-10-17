//
//  MapCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class MapCoordinator: Coordinator {
    private let container: DIContainer
    private let assembly: MapAssembly
    private weak var mapInput: PMapModuleInput?

    init(navigating: UINavigationController, container: DIContainer) {
        self.container = container
        self.assembly = MapAssembly(container: container)
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
            container: container,
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
