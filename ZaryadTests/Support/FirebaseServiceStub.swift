//
//  FirebaseServiceStub.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
@testable import Zaryad

@MainActor
final class FirebaseServiceStub: PFirebaseService {
    // MARK: - Properties -
    var currentAccount: Account?
    let projectID = "zaryad-test"
    let token = "test-id-token"
    // MARK: - Init -
    init(account: Account?) {
        self.currentAccount = account
    }
    // MARK: - PFirebaseService -
    func signIn(email: String, password: String) async throws -> Account { makeAccount(email: email) }
    func signUp(email: String, password: String, displayName: String?) async throws -> Account { makeAccount(email: email) }
    func signOut() throws {}
    func idToken() async throws -> String { token }
    func observeAuthState(owner: AnyObject, _ handler: @escaping @MainActor (Account?) -> Void) {}
}
