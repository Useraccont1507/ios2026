//
//  FavoriteStation.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import Foundation

struct FavoriteStation: Sendable {
    let station: ChargingStation
    let rate: Int
    let note: String?
}
