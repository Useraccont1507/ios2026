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
    private var domainStationsById: [Int: FavoriteStation]
    private let repo: PFavoritesRepository
    private var repoSubscription: FavoritesEventSubscription?
    
    init(repo: PFavoritesRepository) {
        self.state = .loading
        self.repo = repo
        self.domainStationsById = [:]
        self.state = .loading
        subscribeToEvents()
        loadStations()
    }
    func refreshStations() async {
        loadStations(forced: true)
    }
    func remove(station: FavoriteStationUIModel) {
        Task { @MainActor in
            do {
                guard !station.needToDelete else { return }
                guard let domain = domainStationsById[station.id] else { return }
                markAsDelete(for: station, needToDelete: true)
                try await repo.removeFavorite(station: domain)
                loadStations()
            } catch {
                markAsDelete(for: station, needToDelete: false)
            }
        }
    }
    func didTap(station: FavoriteStationUIModel) {
        // TODO: - navigation
    }
    private func loadStations(forced: Bool = false) {
        Task { @MainActor in
            do {
                let result = try await repo.loadFavorites(forced: forced)
                apply(result: result)
            } catch {
                state = .error
            }
        }
    }
    private func apply(result: [FavoriteStation]) {
        state = result.isEmpty ? .empty : .list(stations: FavoriteStationUIMapper().map(result))
        domainStationsById = [:]
        result.forEach {
            domainStationsById[$0.station.id] = $0
        }
    }
    private func markAsDelete(for station: FavoriteStationUIModel, needToDelete: Bool) {
        guard case let .list(stations) = state else { return }
        let modifiedStations = stations.map {
            FavoriteStationUIModel(
                id: $0.id,
                name: $0.name,
                address: $0.address,
                power: $0.power,
                powerKW: $0.powerKW,
                connectorsText: $0.connectorsText,
                rate: $0.rate,
                note: $0.note,
                needToDelete: station == $0 ? needToDelete : $0.needToDelete
            )
        }
        self.state = .list(stations: modifiedStations)
    }
    private func subscribeToEvents() {
        let subscription = repo.observeEvents { [weak self] event in
            guard let self else { return }
            switch event {
            case .needUpdate:
                state = .loading
                loadStations()
            }
        }
        self.repoSubscription = subscription
    }
}
