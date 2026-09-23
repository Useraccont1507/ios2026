//
//  MockFavoritesRepository.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import Foundation

/// TEMP / DEMO: in-memory репозиторій обраного.
/// Заміниться реальним (Firebase Realtime DB) на етапі мережі (лаб 4).
final class MockFavoritesRepository: PFavoritesRepository, Sendable {

    private var favorites: [FavoriteStation]
    private var handlers: [@MainActor @Sendable (FavoritesStationEvent) -> Void] = []

    init(favorites: [FavoriteStation] = MockFavoritesRepository.mockFavorites) {
        self.favorites = favorites
    }

    func loadFavorites(forced: Bool) async throws -> [FavoriteStation] {
        try await Task.sleep(for: .seconds(0.4))   // імітація мережі
        return favorites
    }

    func createFavorite(station: FavoriteStation) async throws {
        try await Task.sleep(for: .seconds(0.2))
        favorites.append(station)
        notify()
    }

    func removeFavorite(station: FavoriteStation) async throws {
        try await Task.sleep(for: .seconds(0.4))
        favorites.removeAll { $0.station.id == station.station.id }
        notify()
    }

    func observeEvents(_ handler: @escaping @MainActor @Sendable (FavoritesStationEvent) -> Void) {
        handlers.append(handler)
    }

    private func notify() {
        let handlers = self.handlers
        Task { @MainActor in
            handlers.forEach { $0(.needUpdate) }
        }
    }
}

// MARK: - Mock data

private extension MockFavoritesRepository {

    static let mockFavorites: [FavoriteStation] = [
        FavoriteStation(
            station: station(id: 1, name: "EcoCharge Хрещатик", address: "вул. Хрещатик, 22",
                             lat: 50.4501, lon: 30.5234, powerKW: 180,
                             connector: (33, "CCS (Type 2)"), operatorName: "EcoCharge", isOperational: true),
            rate: 5, note: "Швидко, є кафе поруч"),

        FavoriteStation(
            station: station(id: 2, name: "YASNO · Арена", address: "пр. Науки, 5",
                             lat: 50.4110, lon: 30.5290, powerKW: 120,
                             connector: (33, "CCS (Type 2)"), operatorName: "YASNO E", isOperational: true),
            rate: 4, note: nil),

        FavoriteStation(
            station: station(id: 3, name: "GO TO-U · Поділ", address: "вул. Сагайдачного, 10",
                             lat: 50.4650, lon: 30.5150, powerKW: 60,
                             connector: (25, "Type 2"), operatorName: "GO TO-U", isOperational: true),
            rate: 3, note: "Іноді зайнято ввечері"),

        FavoriteStation(
            station: station(id: 4, name: "City Charge · Оболонь", address: "пр. Оболонський, 1",
                             lat: 50.5010, lon: 30.4980, powerKW: 22,
                             connector: (25, "Type 2"), operatorName: "City Charge", isOperational: false),
            rate: 4, note: nil),
    ]

    /// Компактна фабрика станції для моків.
    static func station(
        id: Int, name: String, address: String,
        lat: Double, lon: Double, powerKW: Int,
        connector: (id: Int, title: String), operatorName: String, isOperational: Bool
    ) -> ChargingStation {
        ChargingStation(
            id: id,
            uuid: UUID().uuidString,
            addressInfo: .init(
                title: name,
                addressLine1: address,
                town: "Київ",
                postcode: nil,
                country: .init(isoCode: "UA", title: "Ukraine"),
                latitude: lat,
                longitude: lon,
                contactTelephone1: nil,
                distance: nil,
                distanceUnit: 2
            ),
            operatorInfo: .init(id: nil, title: operatorName, websiteURL: nil),
            usageType: .init(id: 1, title: "Public", isPayAtLocation: true),
            statusType: .init(
                id: 50,
                title: isOperational ? "Operational" : "Temporarily Unavailable",
                isOperational: isOperational
            ),
            connections: [
                .init(
                    id: 1,
                    connectionType: .init(id: connector.id, title: connector.title, formalName: nil),
                    currentType: .init(id: 30, title: "DC"),
                    level: .init(id: 3, title: "Level 3", isFastChargeCapable: powerKW >= 50),
                    powerKW: powerKW,
                    quantity: 2,
                    amps: 200,
                    voltage: 400
                )
            ],
            numberOfPoints: 2,
            generalComments: nil,
            dateLastVerified: Date()
        )
    }
}
