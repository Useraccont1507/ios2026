//
//  FavoritesAssembly.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit
import SwiftUI

struct FavoritesAssembly {
    // TODO: - inject real repository (лаб 4)
    private let repo: PFavoritesRepository

    init(repo: PFavoritesRepository = MockFavoritesRepository()) {
        self.repo = repo
    }

    func makeFavoritesList() -> UIViewController {
        let vm = FavoriteListVM(repo: repo)
        return UIHostingController(rootView: FavoritesListView(vm: vm))
    }
}
