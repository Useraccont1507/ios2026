//
//  FavoritesCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class FavoritesCoordinator: Coordinator {
    enum Completion {
        case showOnMap(ChargingStation)
    }

    private var completeBlock: ((FavoritesCoordinator, Completion) -> Void)?
    private let assembly = FavoritesAssembly()

    override func start() {
        naviagateToList()
    }

    @discardableResult
    func onComplete(_ completeBlock: ((FavoritesCoordinator, Completion) -> Void)?) -> Self {
        self.completeBlock = completeBlock
        return self
    }

    private func didFinish(_ completion: Completion) {
        completeBlock?(self, completion)
    }
    
    private func naviagateToList() {
        let vc = assembly.makeFavoritesList { [weak self] station in
            self?.didFinish(.showOnMap(station))
        }
        navigating.setViewControllers([vc], animated: false)
    }
}
