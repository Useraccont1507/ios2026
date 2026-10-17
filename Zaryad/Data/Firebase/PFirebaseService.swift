//
//  PFirebaseService.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PFirebaseService {
    var currentAccount: Account? { get }
    var projectID: String { get }

    func signIn(email: String, password: String) async throws -> Account
    func signUp(email: String, password: String, displayName: String?) async throws -> Account
    func signOut() throws
    func idToken() async throws -> String
    func observeAuthState(owner: AnyObject, _ handler: @escaping @MainActor (Account?) -> Void)
}
