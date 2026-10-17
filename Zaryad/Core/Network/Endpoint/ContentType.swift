//
//  ContentType.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

enum ContentType: Sendable {
    case json
    case formURLEncoded
    case custom(String)

    var value: String {
        switch self {
        case .json: "application/json"
        case .formURLEncoded: "application/x-www-form-urlencoded"
        case .custom(let value): value
        }
    }
}
