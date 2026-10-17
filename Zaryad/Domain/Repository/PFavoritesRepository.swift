//
//  PFavoritesRepository.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import Foundation

protocol PFavoritesRepository {
    func loadFavorites(forced: Bool) async throws -> [FavoriteStation]
    func createFavorite(station: FavoriteStation) async throws
    func removeFavorite(station: FavoriteStation) async throws
    /// Прибирає локальну копію обраного (хмарні дані акаунта не чіпає).
    func clearLocal() async throws
    /// `owner` тримається слабко: коли він звільняється, підписка зникає.
    func observeEvents(owner: AnyObject, _ handler: @escaping @MainActor (FavoritesStationEvent) -> Void)
}
