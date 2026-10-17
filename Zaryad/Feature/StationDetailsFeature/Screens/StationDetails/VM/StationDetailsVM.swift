//
//  StationDetailsVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Combine
import UIKit

final class StationDetailsVM: PStationDetailsVM {
    let details: StationDetailsUIModel
    @Published private(set) var favoriteState: StationFavoriteState
    @Published private(set) var isFavoriteProcessing: Bool
    @Published var isRatingAlertPresented: Bool

    var onShowOnMap: ((ChargingStation) -> Void)?

    private let station: ChargingStation
    private let favoritesRepo: PFavoritesRepository
    private var favorite: FavoriteStation?

    init(station: ChargingStation, favoritesRepo: PFavoritesRepository) {
        self.station = station
        self.favoritesRepo = favoritesRepo
        self.details = StationDetailsUIMapper().map(station)
        self.favoriteState = .loading
        self.isFavoriteProcessing = false
        self.isRatingAlertPresented = false
        subscribeToEvents()
        loadFavoriteState()
    }
    func favoriteButtonTapped() {
        guard !isFavoriteProcessing else { return }
        switch favoriteState {
        case .loading:
            return
        case .notFavorite:
            isRatingAlertPresented = true
        case .favorite:
            removeFromFavorites()
        }
    }
    func addToFavorites(rate: Int) {
        let favorite = FavoriteStation(station: station, rate: rate, note: nil)
        perform { [favoritesRepo] in
            try await favoritesRepo.createFavorite(station: favorite)
        }
    }
    func openRoute() {
        let coordinate = details.coordinate
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "daddr", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "dirflg", value: "d")
        ]
        guard let url = components?.url else { return }
        UIApplication.shared.open(url)
    }
    func showOnMap() {
        onShowOnMap?(station)
    }
    private func removeFromFavorites() {
        guard let favorite else { return }
        perform { [favoritesRepo] in
            try await favoritesRepo.removeFavorite(station: favorite)
        }
    }
    private func perform(_ action: @escaping () async throws -> Void) {
        isFavoriteProcessing = true
        Task { @MainActor in
            defer { isFavoriteProcessing = false }
            do {
                try await action()
                await refreshFavoriteState()
            } catch {
                // TODO: - show error
            }
        }
    }
    private func loadFavoriteState() {
        Task { @MainActor in
            await refreshFavoriteState()
        }
    }
    private func refreshFavoriteState() async {
        let favorites = (try? await favoritesRepo.loadFavorites(forced: false)) ?? []
        favorite = favorites.first { $0.station.id == station.id }
        favoriteState = favorite.map { .favorite(rate: $0.rate) } ?? .notFavorite
    }
    private func subscribeToEvents() {
        favoritesRepo.observeEvents { [weak self] event in
            switch event {
            case .needUpdate:
                self?.loadFavoriteState()
            }
        }
    }
}
