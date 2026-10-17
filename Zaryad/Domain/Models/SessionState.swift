//
//  SessionState.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

enum SessionState: Sendable, Equatable {
    case guest
    case authenticating
    case authorized(Account)
    case refreshingToken(Account)
}

extension SessionState {
    var account: Account? {
        switch self {
        case .authorized(let account), .refreshingToken(let account): account
        case .guest, .authenticating: nil
        }
    }
}
