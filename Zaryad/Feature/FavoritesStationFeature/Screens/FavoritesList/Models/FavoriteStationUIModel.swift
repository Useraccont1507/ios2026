//
//  FavoriteStationUIModel.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import UIKit

struct FavoriteStationUIModel: Identifiable, Equatable {
    let id: UUID
    let stationId: Int
    let name: String
    let address: String
    let power: PowerTier
    let powerKW: Int?
    let connectorsText: String
    let rate: Int
    let note: String?
    let needToDelete: Bool
}

enum PowerTier: Equatable {
    case slow, fast, high, ultra

    init(kW: Int?) {
        switch kW ?? 0 {
        case ..<23:    self = .slow
        case 23..<75:  self = .fast
        case 75..<150: self = .high
        default:       self = .ultra
        }
    }
    var color: UIColor {
        switch self {
        case .slow:  return .systemGreen
        case .fast:  return .systemYellow
        case .high:  return .systemOrange
        case .ultra: return .systemRed
        }
    }
    var title: String {
        switch self {
        case .slow: "Повільна"
        case .fast: "Швидка"
        case .high: "Потужна"
        case .ultra: "Надшвидка"
        }
    }
}
