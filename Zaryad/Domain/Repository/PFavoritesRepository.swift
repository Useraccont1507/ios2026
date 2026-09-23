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
    func removeFavorite(station: FavoriteStation, forced: Bool) async throws
    func observeEvents(_ handler: @escaping @MainActor (FavoritesStationEvent) -> Void) -> FavoritesEventSubscription
}
