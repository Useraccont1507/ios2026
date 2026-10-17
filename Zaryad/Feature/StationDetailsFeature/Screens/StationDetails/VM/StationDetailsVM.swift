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
    @Published var isRatingPopupPresented: Bool

    var onShowOnMap: ((ChargingStation) -> Void)?
    var onAuthRequired: (() -> Void)?

    private let station: ChargingStation
    private let favoritesRepo: PFavoritesRepository
    private let authRepo: PAuthRepository
    private var favorite: FavoriteStation?

    init(station: ChargingStation, favoritesRepo: PFavoritesRepository, authRepo: PAuthRepository) {
        self.station = station
        self.favoritesRepo = favoritesRepo
        self.authRepo = authRepo
        self.details = StationDetailsUIMapper().map(station)
        self.favoriteState = .loading
        self.isFavoriteProcessing = false
        self.isRatingPopupPresented = false
        subscribeToEvents()
        loadFavoriteState()
    }
    func favoriteButtonTapped() {
        guard !isFavoriteProcessing else { return }
        switch favoriteState {
        case .loading:
            return
        case .notFavorite:
            guard authRepo.session.account != nil else {
                onAuthRequired?()
                return
            }
            isRatingPopupPresented = true
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
        favoritesRepo.observeEvents(owner: self) { [weak self] event in
            switch event {
            case .needUpdate:
                self?.loadFavoriteState()
            }
        }
    }
}
