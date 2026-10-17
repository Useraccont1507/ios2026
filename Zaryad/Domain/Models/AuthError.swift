//
//  AuthError.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Доменні помилки автентифікації (мапляться з кодів Firebase Auth).
enum AuthError: Error, Sendable, Equatable {
    case invalidEmail
    case weakPassword
    case invalidCredentials
    case emailAlreadyInUse
    /// Дія потребує входу в акаунт.
    case unauthorized
    case network
    case unknown
}
