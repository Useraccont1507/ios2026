//
//  PAuthVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PAuthVM: ObservableObject {
    var mode: AuthMode { get set }
    var displayName: String { get set }
    var email: String { get set }
    var password: String { get set }
    var isLoading: Bool { get }
    var errorText: String? { get }
    var canSubmit: Bool { get }

    func submit()
}
