//
//  AuthRepositorySpy.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
@testable import Zaryad

@MainActor
final class AuthRepositorySpy: PAuthRepository {
    // MARK: - Properties -
    var signInResult: Result<Account, Error> = .success(makeAccount())
    var signUpResult: Result<Account, Error> = .success(makeAccount())
    private(set) var calls: [String] = []
    var session: SessionState = .guest
    // MARK: - PAuthRepository -
    func signIn(email: String, password: String) async throws -> Account {
        calls.append("signIn:\(email)")
        return try signInResult.get()
    }
    func signUp(email: String, password: String, displayName: String?) async throws -> Account {
        calls.append("signUp:\(email):\(displayName ?? "-")")
        return try signUpResult.get()
    }
    func signOut() async throws {
        calls.append("signOut")
    }
    func observeSession(owner: AnyObject, _ handler: @escaping @MainActor (SessionState) -> Void) {}
}
