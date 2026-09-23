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
    
    init(repo: PFavoritesRepository) {
        self.state = .loading
        self.repo = repo
        self.domainStationsById = [:]
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
                guard let domain = domainStationsById[station.stationId] else { return }
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

    // MARK: - TEMP DEMO — прибрати, коли додавання переїде на MapView
    func addDemoStation() {
        Task { @MainActor in
            try? await repo.createFavorite(station: Self.makeDemoFavorite())
            loadStations()
        }
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
                stationId: $0.stationId,
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
        repo.observeEvents { [weak self] event in
            guard let self else { return }
            switch event {
            case .needUpdate:
                state = .loading
                loadStations()
            }
        }
    }
}

extension FavoriteListVM {
    private static func makeDemoFavorite() -> FavoriteStation {
        let names = ["Nova Charge", "PowerUp", "VoltHub", "GreenPlug"]
        let powers = [22, 60, 120, 180]
        let i = Int.random(in: 0..<names.count)
        let station = ChargingStation(
            id: Int.random(in: 1000...9999),
            uuid: nil,
            addressInfo: .init(title: names[i], addressLine1: "вул. Демо, \(Int.random(in: 1...99))",
                               town: "Київ", postcode: nil, country: nil,
                               latitude: 50.45, longitude: 30.52, contactTelephone1: nil,
                               distance: nil, distanceUnit: nil),
            operatorInfo: .init(id: nil, title: names[i], websiteURL: nil),
            usageType: nil,
            statusType: .init(id: nil, title: "Operational", isOperational: true),
            connections: [.init(id: nil,
                                connectionType: .init(id: 25, title: "Type 2", formalName: nil),
                                currentType: nil, level: nil, powerKW: powers.randomElement(),
                                quantity: 1, amps: nil, voltage: nil)],
            numberOfPoints: nil, generalComments: nil, dateLastVerified: nil)
        return FavoriteStation(station: station, rate: Int.random(in: 3...5), note: nil)
    }
}
