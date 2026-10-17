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

    init(favoritesRepo: PFavoritesRepository) {
        self.favoritesRepo = favoritesRepo
    }

    func makeStationDetails(
        station: ChargingStation,
        onShowOnMap: @escaping (ChargingStation) -> Void,
        onClose: @escaping () -> Void
    ) -> UIViewController {
        let vm = StationDetailsVM(station: station, favoritesRepo: favoritesRepo)
        vm.onShowOnMap = onShowOnMap
        let vc = HostingController(rootView: StationDetailsView(vm: vm))
        vc.onRemoveFromParent = onClose
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
}
