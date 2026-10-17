//
//  ProfileAssembly.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import UIKit
import SwiftUI

struct ProfileAssembly {
    private let authRepo: PAuthRepository
    private let favoritesRepo: PFavoritesRepository

    init(authRepo: PAuthRepository, favoritesRepo: PFavoritesRepository) {
        self.authRepo = authRepo
        self.favoritesRepo = favoritesRepo
    }

    func makeProfile(
        onSignIn: @escaping () -> Void,
        onSignUp: @escaping () -> Void,
        onSignedOut: @escaping () -> Void
    ) -> UIViewController {
        let vm = ProfileVM(authRepo: authRepo, favoritesRepo: favoritesRepo)
        vm.onSignIn = onSignIn
        vm.onSignUp = onSignUp
        vm.onSignedOut = onSignedOut
        return UIHostingController(rootView: ProfileView(vm: vm))
    }

    func makeAuth(
        mode: AuthMode,
        onSuccess: @escaping (Account) -> Void
    ) -> UIViewController {
        let vm = AuthVM(mode: mode, authRepo: authRepo)
        vm.onSuccess = onSuccess
        let vc = UIHostingController(rootView: AuthView(vm: vm))
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
}
