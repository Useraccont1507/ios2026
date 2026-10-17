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

    init(container: DIContainer) {
        self.stationsRepo = container.stationsRepository
    }

    func makeMap(
        onOpenDetails: @escaping (ChargingStation) -> Void
    ) -> (vc: UIViewController, input: PMapModuleInput) {
        let vm = MapVM(repo: stationsRepo)
        vm.onOpenDetails = onOpenDetails
        let vc = UIHostingController(rootView: MapScreenView(vm: vm))
        return (vc, vm)
    }
}
