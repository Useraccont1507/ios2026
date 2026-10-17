//
//  FavoriteStationDTO.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Документ обраного у Firestore: `users/{uid}/favorites/{stationId}`.
nonisolated struct FavoriteStationDTO: Codable, Sendable {
    let station: OCMStationDTO
    let rate: Int
    let note: String?
    /// Unix-час додавання — для сортування списку.
    let addedAt: Double?
}
