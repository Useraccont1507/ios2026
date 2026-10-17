//
//  FirebaseService.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import FirebaseAuth
import FirebaseCore
import Foundation

final class FirebaseService: PFirebaseService {
    private var authListener: AuthStateDidChangeListenerHandle?
    private let observers = ObserverList<Account?>()

    static func configure() {
        FirebaseApp.configure()
    }

    init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            let account = user.map(Self.account)
            Task { @MainActor in
                self?.observers.notify(account)
            }
        }
    }

    deinit {
        if let authListener { Auth.auth().removeStateDidChangeListener(authListener) }
    }

    var currentAccount: Account? {
        Auth.auth().currentUser.map(Self.account)
    }

    var projectID: String {
        guard let projectID = FirebaseApp.app()?.options.projectID else {
            preconditionFailure("Firebase не налаштований: немає GoogleService-Info.plist")
        }
        return projectID
    }

    func signIn(email: String, password: String) async throws -> Account {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return Self.account(from: result.user)
        } catch {
            throw Self.authError(from: error)
        }
    }

    func signUp(email: String, password: String, displayName: String?) async throws -> Account {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            if let displayName, !displayName.isEmpty {
                let request = result.user.createProfileChangeRequest()
                request.displayName = displayName
                try await request.commitChanges()
            }
            return Self.account(from: result.user)
        } catch {
            throw Self.authError(from: error)
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func idToken() async throws -> String {
        guard let user = Auth.auth().currentUser else { throw AuthError.unauthorized }
        do {
            return try await user.getIDToken()
        } catch {
            throw Self.authError(from: error)
        }
    }

    func observeAuthState(owner: AnyObject, _ handler: @escaping @MainActor (Account?) -> Void) {
        observers.add(owner: owner, handler)
    }

    nonisolated private static func account(from user: User) -> Account {
        Account(
            id: user.uid,
            email: user.email ?? "",
            displayName: user.displayName,
            createdAt: user.metadata.creationDate ?? Date()
        )
    }

    private static func authError(from error: Error) -> AuthError {
        guard let code = AuthErrorCode(rawValue: (error as NSError).code) else { return .unknown }
        switch code {
        case .invalidEmail: return .invalidEmail
        case .weakPassword: return .weakPassword
        case .wrongPassword, .userNotFound, .invalidCredential: return .invalidCredentials
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .networkError: return .network
        case .userTokenExpired, .invalidUserToken, .userDisabled: return .unauthorized
        default: return .unknown
        }
    }
}
