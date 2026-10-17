//
//  Coordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit
import Foundation

class Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    var navigating: UINavigationController
    var sourceVC: UIViewController?
    
    init(navigating: UINavigationController) {
        self.navigating = navigating
        self.sourceVC = navigating.navigationController?.viewControllers.last
    }
    
    func start() {}
}

extension Coordinator {
    @discardableResult
    func store(in parent: Coordinator) -> Self {
        parentCoordinator = parent
        parent.childCoordinators.append(self)
        return self
    }
    @discardableResult
    func storeAndStart(in parent: Coordinator) -> Self {
        store(in: parent)
        self.start()
        return self
    }
    func free() {
        self.parentCoordinator?.childCoordinators.removeAll(where: {$0 === self})
    }
    func free(coordinator: Coordinator) {
        self.childCoordinators.removeAll(where: {$0 === self})
    }
}
