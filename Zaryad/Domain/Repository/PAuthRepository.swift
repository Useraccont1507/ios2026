//
//  PAuthRepository.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PAuthRepository {
    var session: SessionState { get }

    func signIn(email: String, password: String) async throws -> Account
    func signUp(email: String, password: String, displayName: String?) async throws -> Account
    func signOut() async throws
    func observeSession(_ handler: @escaping @MainActor (SessionState) -> Void)
}
