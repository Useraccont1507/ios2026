//
//  PFirebaseService.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Єдина точка доступу до Firebase SDK. Через SDK — тільки автентифікація й токени;
/// дані (Firestore) — по HTTP через `RequestManager` + `FirestoreEndpoint`.
protocol PFirebaseService {
    var currentAccount: Account? { get }
    var projectID: String? { get }

    func signIn(email: String, password: String) async throws -> Account
    func signUp(email: String, password: String, displayName: String?) async throws -> Account
    func signOut() throws
    /// ID-токен поточного користувача для `?auth=` у REST-запитах (SDK сам оновлює протермінований).
    func idToken() async throws -> String
    /// `owner` тримається слабко: коли він звільняється, підписка зникає.
    func observeAuthState(owner: AnyObject, _ handler: @escaping @MainActor (Account?) -> Void)
}
