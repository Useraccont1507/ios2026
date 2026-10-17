//
//  Account.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Акаунт користувача (Firebase Auth).
struct Account: Sendable, Equatable {
    /// Firebase `uid`.
    let id: String
    let email: String
    let displayName: String?
    let createdAt: Date
}
