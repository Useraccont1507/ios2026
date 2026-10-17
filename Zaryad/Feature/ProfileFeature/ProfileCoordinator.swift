//
//  ProfileCoordinator.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit

final class ProfileCoordinator: Coordinator {
    weak var delegate: PProfileCoordinatorDelegate?
    private let assembly: ProfileAssembly

    init(
        navigating: UINavigationController,
        authRepository: PAuthRepository,
        favoritesRepository: PFavoritesRepository
    ) {
        self.assembly = ProfileAssembly(authRepo: authRepository, favoritesRepo: favoritesRepository)
        super.init(navigating: navigating)
    }

    override func start() {
        navigateToProfile()
    }

    private func navigateToProfile() {
        let vc = assembly.makeProfile(
            onSignIn: { [weak self] in self?.navigateToAuth(mode: .signIn) },
            onSignUp: { [weak self] in self?.navigateToAuth(mode: .signUp) },
            onSignedOut: { [weak self] in
                guard let self else { return }
                delegate?.profileCoordinatorDidSignOut(self)
            }
        )
        navigating.setViewControllers([vc], animated: false)
    }

    private func navigateToAuth(mode: AuthMode) {
        let vc = assembly.makeAuth(mode: mode) { [weak self] _ in
            self?.navigating.popToRootViewController(animated: true)
        }
        navigating.pushViewController(vc, animated: true)
    }
}

// MARK: - PProfileProvider
extension ProfileCoordinator: PProfileProvider {
    func showProfile() {
        navigating.popToRootViewController(animated: false)
    }
}
