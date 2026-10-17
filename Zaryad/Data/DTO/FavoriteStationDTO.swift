//
//  FavoriteStationDTO.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

nonisolated struct FavoriteStationDTO: Codable, Sendable {
    let station: OCMStationDTO
    let rate: Int
    let note: String?
    let addedAt: Double?
}
