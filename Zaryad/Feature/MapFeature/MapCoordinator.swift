//
//  MapCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class MapCoordinator: Coordinator {
    private let assembly = MapAssembly()
    private weak var mapInput: PMapModuleInput?

    override func start() {
        navigateToMap()
    }

    func showStation(id: Int, at coordinate: Coordinate) {
        navigating.popToRootViewController(animated: false)
        mapInput?.showStation(id: id, at: coordinate)
    }

    private func navigateToMap() {
        let module = assembly.makeMap { [weak self] station in
            self?.navigateToStationDetails(station)
        }
        mapInput = module.input
        navigating.setViewControllers([module.vc], animated: false)
    }

    private func navigateToStationDetails(_ station: ChargingStation) {
        // TODO: - station details screen
    }
}
