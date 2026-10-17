//
//  MapAssembly.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit
import SwiftUI

struct MapAssembly {
    private let stationsRepo: PStationsRepository
    private let locationService: PLocationService

    init(stationsRepo: PStationsRepository, locationService: PLocationService) {
        self.stationsRepo = stationsRepo
        self.locationService = locationService
    }

    func makeMap(
        onOpenDetails: @escaping (ChargingStation) -> Void
    ) -> (vc: UIViewController, input: PMapModuleInput) {
        let vm = MapVM(repo: stationsRepo, locationService: locationService)
        vm.onOpenDetails = onOpenDetails
        let vc = UIHostingController(rootView: MapScreenView(vm: vm))
        return (vc, vm)
    }
}
