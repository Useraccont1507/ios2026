//
//  AuthVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Combine
import Foundation

final class AuthVM: PAuthVM {
    @Published var mode: AuthMode {
        didSet { errorText = nil }
    }
    @Published var displayName: String
    @Published var email: String
    @Published var password: String
    @Published private(set) var isLoading: Bool
    @Published private(set) var errorText: String?

    var onSuccess: ((Account) -> Void)?

    private let authRepo: PAuthRepository

    init(mode: AuthMode, authRepo: PAuthRepository) {
        self.mode = mode
        self.authRepo = authRepo
        self.displayName = ""
        self.email = ""
        self.password = ""
        self.isLoading = false
    }
    var canSubmit: Bool {
        !isLoading && !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }
    func submit() {
        guard canSubmit else { return }
        isLoading = true
        errorText = nil
        Task { @MainActor in
            defer { isLoading = false }
            do {
                let account = switch mode {
                case .signIn:
                    try await authRepo.signIn(email: email, password: password)
                case .signUp:
                    try await authRepo.signUp(email: email, password: password, displayName: displayName)
                }
                onSuccess?(account)
            } catch {
                errorText = Self.message(for: error)
            }
        }
    }
    private static func message(for error: Error) -> String {
        switch error as? AuthError {
        case .invalidEmail: "Перевірте формат email."
        case .weakPassword: "Пароль має містити щонайменше 6 символів."
        case .invalidCredentials: "Невірний email або пароль."
        case .emailAlreadyInUse: "Акаунт з таким email уже існує. Спробуйте увійти."
        case .unauthorized: "Спершу увійдіть в акаунт."
        case .network: "Немає з'єднання. Спробуйте ще раз."
        case .unknown, .none: "Щось пішло не так. Спробуйте ще раз."
        }
    }
}
