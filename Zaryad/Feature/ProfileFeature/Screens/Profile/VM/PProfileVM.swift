//
//  PProfileVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PProfileVM: ObservableObject {
    var state: ProfileViewState { get }
    var isSigningOut: Bool { get }
    var isSignOutConfirmationPresented: Bool { get set }

    func signInTapped()
    func signUpTapped()
    func signOutTapped()
    func confirmSignOut()
}
