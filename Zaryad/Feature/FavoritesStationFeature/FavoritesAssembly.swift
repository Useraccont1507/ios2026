//
//  FavoritesAssembly.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit
import SwiftUI

struct FavoritesAssembly {
    private let repo: PFavoritesRepository

    init(container: DIContainer) {
        self.repo = container.favoritesRepository
    }

    func makeFavoritesList(onStationTap: @escaping (ChargingStation) -> Void) -> UIViewController {
        let vm = FavoriteListVM(repo: repo)
        vm.onStationTap = onStationTap
        return UIHostingController(rootView: FavoritesListView(vm: vm))
    }
}
