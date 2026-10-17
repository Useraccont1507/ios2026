//
//  FavoritesCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class FavoritesCoordinator: Coordinator {
    private let assembly = FavoritesAssembly()

    override func start() {
        let vc = assembly.makeFavoritesList()
        navigating.setViewControllers([vc], animated: false)
    }
}
