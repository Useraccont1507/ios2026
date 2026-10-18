//
//  AuthVMTests.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
import Testing
@testable import Zaryad

@MainActor
@Suite("AuthVM")
struct AuthVMTests {
    // MARK: - canSubmit -
    @Test("Порожній email або пароль → кнопка неактивна")
    func canSubmit_emptyFields_isFalse() {
        let vm = AuthVM(mode: .signIn, authRepo: AuthRepositorySpy())
        #expect(vm.canSubmit == false)
        vm.email = "  "
        vm.password = "secret1"
        #expect(vm.canSubmit == false)
        vm.email = "a@b.co"
        #expect(vm.canSubmit == true)
    }
    // MARK: - submit -
    @Test("Вхід успішний → onSuccess з акаунтом, помилки немає (FR-5)")
    func submit_signInSuccess_callsOnSuccess() async {
        let repo = AuthRepositorySpy()
        let vm = AuthVM(mode: .signIn, authRepo: repo)
        var received: [String] = []
        vm.onSuccess = { received.append($0.id) }
        vm.email = "driver@zaryad.app"
        vm.password = "secret1"
        vm.submit()
        await settle()
        #expect(repo.calls == ["signIn:driver@zaryad.app"])
        #expect(received == ["uid-1"])
        #expect(vm.errorText == nil)
        #expect(vm.isLoading == false)
    }
    @Test("Реєстрація передає ім'я в репозиторій (FR-4)")
    func submit_signUp_passesDisplayName() async {
        let repo = AuthRepositorySpy()
        let vm = AuthVM(mode: .signUp, authRepo: repo)
        vm.displayName = "Ілля"
        vm.email = "new@zaryad.app"
        vm.password = "secret1"
        vm.submit()
        await settle()
        #expect(repo.calls == ["signUp:new@zaryad.app:Ілля"])
    }
    @Test("Помилка автентифікації → зрозуміле повідомлення", arguments: [
        (AuthError.invalidCredentials, "Невірний email або пароль."),
        (.weakPassword, "Пароль має містити щонайменше 6 символів."),
        (.emailAlreadyInUse, "Акаунт з таким email уже існує. Спробуйте увійти."),
        (.network, "Немає з'єднання. Спробуйте ще раз.")
    ])
    func submit_authError_showsMessage(error: AuthError, message: String) async {
        let repo = AuthRepositorySpy()
        repo.signInResult = .failure(error)
        let vm = AuthVM(mode: .signIn, authRepo: repo)
        vm.email = "driver@zaryad.app"
        vm.password = "secret1"
        vm.submit()
        await settle()
        #expect(vm.errorText == message)
    }
    @Test("Перемикання режиму прибирає стару помилку")
    func mode_change_clearsError() async {
        let repo = AuthRepositorySpy()
        repo.signInResult = .failure(AuthError.invalidCredentials)
        let vm = AuthVM(mode: .signIn, authRepo: repo)
        vm.email = "driver@zaryad.app"
        vm.password = "secret1"
        vm.submit()
        await settle()
        vm.mode = .signUp
        #expect(vm.errorText == nil)
    }
}
