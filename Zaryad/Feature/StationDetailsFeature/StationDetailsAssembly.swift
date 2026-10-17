//
//  StationDetailsAssembly.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit
import SwiftUI

struct StationDetailsAssembly {
    private let favoritesRepo: PFavoritesRepository
    private let authRepo: PAuthRepository

    init(favoritesRepo: PFavoritesRepository, authRepo: PAuthRepository) {
        self.favoritesRepo = favoritesRepo
        self.authRepo = authRepo
    }

    func makeStationDetails(
        station: ChargingStation,
        onShowOnMap: @escaping (ChargingStation) -> Void,
        onAuthRequired: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) -> UIViewController {
        let vm = StationDetailsVM(station: station, favoritesRepo: favoritesRepo, authRepo: authRepo)
        vm.onShowOnMap = onShowOnMap
        vm.onAuthRequired = onAuthRequired
        let vc = HostingController(rootView: StationDetailsView(vm: vm))
        vc.onRemoveFromParent = onClose
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
}
