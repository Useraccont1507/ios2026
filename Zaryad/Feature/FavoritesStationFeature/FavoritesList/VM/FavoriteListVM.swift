//
//  FavoriteListVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import Combine
import Foundation

final class FavoriteListVM: PFavoriteListVM {
    @Published var state: FavoriteListViewState
    private var domainStations: [FavoriteStation]
    private let repo: PFavoritesRepository
    
    init(repo: PFavoritesRepository) {
        self.state = .loading
        self.repo = repo
        self.domainStations = []
        loadStations()
    }
    func refreshStations() {
        loadStations(forced: true)
    }
    private func loadStations(forced: Bool = false) {
        Task { @MainActor in
            do {
                state = .loading
                domainStations = try await repo.loadFavorites(forced: forced)
                state = .list(stations: FavoriteStationUIMapper().map(domainStations))
            } catch {
                state = .error
            }
        }
    }
}
