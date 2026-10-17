//
//  MapAssembly.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit
import SwiftUI

struct MapAssembly {
    // TODO: - inject real repository (лаб 4)
    private let repo: PStationsRepository

    init(repo: PStationsRepository = MockStationsRepository()) {
        self.repo = repo
    }

    func makeMap(
        onStationSelected: @escaping (ChargingStation) -> Void
    ) -> (vc: UIViewController, input: PMapModuleInput) {
        let vm = MapVM(repo: repo)
        vm.onStationSelected = onStationSelected
        let vc = UIHostingController(rootView: MapScreenView(vm: vm))
        return (vc, vm)
    }
}
