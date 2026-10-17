//
//  MockAuthRepository.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// TEMP / DEMO: in-memory автентифікація.
/// Заміниться реальною (Firebase Auth) на етапі мережі (лаб 4).
/// Правила валідації — як у Firebase: email має бути валідним, пароль — від 6 символів.
final class MockAuthRepository: PAuthRepository, Sendable {

    private(set) var session: SessionState = .guest {
        didSet { notify() }
    }
    private var users: [String: MockUser]
    private let observers = ObserverList<SessionState>()

    init(users: [MockUser] = MockAuthRepository.mockUsers) {
        self.users = Dictionary(uniqueKeysWithValues: users.map { ($0.account.email.lowercased(), $0) })
    }

    func signIn(email: String, password: String) async throws -> Account {
        let email = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard Self.isValid(email: email) else { throw AuthError.invalidEmail }

        session = .authenticating
        try await Task.sleep(for: .seconds(0.8))

        guard let user = users[email], user.password == password else {
            session = .guest
            throw AuthError.invalidCredentials
        }
        session = .authorized(user.account)
        return user.account
    }

    func signUp(email: String, password: String, displayName: String?) async throws -> Account {
        let email = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard Self.isValid(email: email) else { throw AuthError.invalidEmail }
        guard password.count >= 6 else { throw AuthError.weakPassword }

        session = .authenticating
        try await Task.sleep(for: .seconds(0.8))

        guard users[email] == nil else {
            session = .guest
            throw AuthError.emailAlreadyInUse
        }
        let name = displayName?.trimmingCharacters(in: .whitespaces)
        let account = Account(
            id: UUID().uuidString,
            email: email,
            displayName: name?.isEmpty == false ? name : nil,
            createdAt: Date()
        )
        users[email] = MockUser(account: account, password: password)
        session = .authorized(account)
        return account
    }

    func signOut() async throws {
        try await Task.sleep(for: .seconds(0.3))
        session = .guest
    }

    func observeSession(owner: AnyObject, _ handler: @escaping @MainActor (SessionState) -> Void) {
        observers.add(owner: owner, handler)
    }

    private func notify() {
        observers.notify(session)
    }

    private static func isValid(email: String) -> Bool {
        email.range(of: #"^[^@\s]+@[^@\s]+\.[^@\s]+$"#, options: .regularExpression) != nil
    }
}

// MARK: - Mock data

extension MockAuthRepository {
    struct MockUser: Sendable {
        let account: Account
        let password: String
    }

    static let demoUserId = "mock-uid-1"

    static let mockUsers: [MockUser] = [
        MockUser(
            account: Account(
                id: demoUserId,
                email: "demo@zaryad.app",
                displayName: "Демо Водій",
                createdAt: Date(timeIntervalSince1970: 1_790_000_000)
            ),
            password: "zaryad123"
        )
    ]
}
