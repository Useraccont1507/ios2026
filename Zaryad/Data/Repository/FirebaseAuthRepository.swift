//
//  FirebaseAuthRepository.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

final class FirebaseAuthRepository: PAuthRepository {
    private(set) var session: SessionState {
        didSet {
            guard session != oldValue else { return }
            notify()
        }
    }
    private let service: PFirebaseService
    private let observers = ObserverList<SessionState>()

    init(service: PFirebaseService) {
        self.service = service
        self.session = service.currentAccount.map { .authorized($0) } ?? .guest
        service.observeAuthState(owner: self) { [weak self] account in
            guard let self, session != .authenticating else { return }
            session = account.map { .authorized($0) } ?? .guest
        }
    }

    func signIn(email: String, password: String) async throws -> Account {
        try await authenticate {
            try await self.service.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
        }
    }

    func signUp(email: String, password: String, displayName: String?) async throws -> Account {
        let name = displayName?.trimmingCharacters(in: .whitespaces)
        return try await authenticate {
            try await self.service.signUp(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password,
                displayName: name?.isEmpty == false ? name : nil
            )
        }
    }

    func signOut() async throws {
        try service.signOut()
        session = .guest
    }

    func observeSession(owner: AnyObject, _ handler: @escaping @MainActor (SessionState) -> Void) {
        observers.add(owner: owner, handler)
    }

    private func authenticate(_ action: () async throws -> Account) async throws -> Account {
        session = .authenticating
        do {
            let account = try await action()
            session = .authorized(account)
            return account
        } catch {
            session = .guest
            throw error
        }
    }

    private func notify() {
        observers.notify(session)
    }
}
