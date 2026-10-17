//
//  ProfileVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Combine
import Foundation

final class ProfileVM: PProfileVM {
    @Published private(set) var state: ProfileViewState
    @Published private(set) var isSigningOut: Bool
    @Published var isSignOutConfirmationPresented: Bool

    var onSignIn: (() -> Void)?
    var onSignUp: (() -> Void)?
    var onSignedOut: (() -> Void)?

    private let authRepo: PAuthRepository
    private let favoritesRepo: PFavoritesRepository
    private var favoritesCount: Int?

    init(authRepo: PAuthRepository, favoritesRepo: PFavoritesRepository) {
        self.authRepo = authRepo
        self.favoritesRepo = favoritesRepo
        self.state = .guest
        self.isSigningOut = false
        self.isSignOutConfirmationPresented = false
        apply(session: authRepo.session)
        subscribeToEvents()
        loadFavoritesCount()
    }
    func signInTapped() {
        onSignIn?()
    }
    func signUpTapped() {
        onSignUp?()
    }
    func signOutTapped() {
        isSignOutConfirmationPresented = true
    }
    func confirmSignOut() {
        guard !isSigningOut else { return }
        isSigningOut = true
        Task { @MainActor in
            defer { isSigningOut = false }
            do {
                try await authRepo.signOut()
                onSignedOut?()
            } catch {
            }
        }
    }
    private func apply(session: SessionState) {
        switch session {
        case .guest:
            state = .guest
        case .authenticating:
            state = .authenticating
        case .authorized(let account), .refreshingToken(let account):
            state = .user(ProfileUIMapper().map(account, favoritesCount: favoritesCount))
        }
    }
    private func loadFavoritesCount() {
        Task { @MainActor in
            favoritesCount = try? await favoritesRepo.loadFavorites(forced: false).count
            apply(session: authRepo.session)
        }
    }
    private func subscribeToEvents() {
        authRepo.observeSession(owner: self) { [weak self] session in
            self?.apply(session: session)
        }
        favoritesRepo.observeEvents(owner: self) { [weak self] event in
            switch event {
            case .needUpdate:
                self?.loadFavoritesCount()
            }
        }
    }
}
