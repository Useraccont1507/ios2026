//
//  AuthMode.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

enum AuthMode: CaseIterable {
    case signIn, signUp

    var title: String {
        switch self {
        case .signIn: "Вхід"
        case .signUp: "Реєстрація"
        }
    }
    var submitTitle: String {
        switch self {
        case .signIn: "Увійти"
        case .signUp: "Створити акаунт"
        }
    }
}
