//
//  AuthError.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

enum AuthError: Error, Sendable, Equatable {
    case invalidEmail
    case weakPassword
    case invalidCredentials
    case emailAlreadyInUse
    case unauthorized
    case network
    case unknown
}
