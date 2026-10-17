//
//  MockFavoritesRepository.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import Foundation

/// TEMP / DEMO: in-memory репозиторій обраного.
/// Реальна реалізація — `FirebaseFavoritesRepository` (Firestore, `users/{uid}/favorites`).
/// Обране прив'язане до акаунта: гість бачить порожній список, після входу — обране цього користувача.
final class MockFavoritesRepository: PFavoritesRepository, Sendable {

    /// Імітація хмари: обране кожного користувача за його `uid`.
    private var favoritesByUser: [String: [FavoriteStation]]
    private let observers = ObserverList<FavoritesStationEvent>()
    private let authRepo: PAuthRepository

    init(
        authRepo: PAuthRepository,
        favoritesByUser: [String: [FavoriteStation]] = [MockAuthRepository.demoUserId: MockFavoritesRepository.mockFavorites]
    ) {
        self.authRepo = authRepo
        self.favoritesByUser = favoritesByUser
        subscribeToSession()
    }

    func loadFavorites(forced: Bool) async throws -> [FavoriteStation] {
        try await Task.sleep(for: .seconds(0.4))
        guard let uid = currentUserId else { return [] }
        return favoritesByUser[uid] ?? []
    }

    func createFavorite(station: FavoriteStation) async throws {
        guard let uid = currentUserId else { throw AuthError.unauthorized }
        try await Task.sleep(for: .seconds(0.2))
        favoritesByUser[uid, default: []].append(station)
        notify()
    }

    func removeFavorite(station: FavoriteStation) async throws {
        guard let uid = currentUserId else { throw AuthError.unauthorized }
        try await Task.sleep(for: .seconds(0.4))
        if let index = favoritesByUser[uid]?.firstIndex(where: { $0.station.id == station.station.id }) {
            favoritesByUser[uid]?.remove(at: index)
            notify()
        }
    }

    /// У моку локального кешу немає — дані акаунта лишаються в «хмарі»,
    /// тож тут лише просимо підписників перечитати (гість отримає порожній список).
    func clearLocal() async throws {
        notify()
    }

    func observeEvents(owner: AnyObject, _ handler: @escaping @MainActor (FavoritesStationEvent) -> Void) {
        observers.add(owner: owner, handler)
    }

    private var currentUserId: String? {
        authRepo.session.account?.id
    }

    private func subscribeToSession() {
        authRepo.observeSession(owner: self) { [weak self] session in
            switch session {
            case .guest, .authorized:
                self?.notify()
            case .authenticating, .refreshingToken:
                break
            }
        }
    }

    private func notify() {
        observers.notify(.needUpdate)
    }
}

// MARK: - Mock data

extension MockFavoritesRepository {

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
    private static func station(
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
