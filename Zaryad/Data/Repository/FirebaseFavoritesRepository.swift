//
//  FirebaseFavoritesRepository.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

final class FirebaseFavoritesRepository: PFavoritesRepository {
    private let service: PFirebaseService
    private let requestManager: PRequestManager
    private let mapper: StationMapper
    private let observers = ObserverList<FavoritesStationEvent>()

    init(
        service: PFirebaseService,
        authRepo: PAuthRepository,
        requestManager: PRequestManager,
        mapper: StationMapper = StationMapper()
    ) {
        self.service = service
        self.requestManager = requestManager
        self.mapper = mapper
        authRepo.observeSession(owner: self) { [weak self] session in
            switch session {
            case .guest, .authorized:
                self?.notify()
            case .authenticating, .refreshingToken:
                break
            }
        }
    }

    func loadFavorites(forced: Bool) async throws -> [FavoriteStation] {
        guard let uid = service.currentAccount?.id else { return [] }
        let token = try await service.idToken()
        let response = try await requestManager.sendData(FirestoreEndpoint.favorites(uid: uid, token: token))
        let records = try FirestoreCoder.decodeDocuments(FavoriteStationDTO.self, from: response.data)
        return records
            .sorted { ($0.addedAt ?? 0) < ($1.addedAt ?? 0) }
            .compactMap { record in
                mapper.map(record.station).map {
                    FavoriteStation(station: $0, rate: record.rate, note: record.note)
                }
            }
    }

    func createFavorite(station: FavoriteStation) async throws {
        let (uid, token) = try await credentials()
        let record = FavoriteStationDTO(
            station: mapper.dto(from: station.station),
            rate: station.rate,
            note: station.note,
            addedAt: Date().timeIntervalSince1970
        )
        let body = try FirestoreCoder.documentBody(record)
        _ = try await requestManager.sendData(
            FirestoreEndpoint.putFavorite(body, stationId: station.station.id, uid: uid, token: token)
        )
        notify()
    }

    func removeFavorite(station: FavoriteStation) async throws {
        let (uid, token) = try await credentials()
        _ = try await requestManager.sendData(
            FirestoreEndpoint.deleteFavorite(stationId: station.station.id, uid: uid, token: token)
        )
        notify()
    }

    func clearLocal() async throws {
        notify()
    }

    func observeEvents(owner: AnyObject, _ handler: @escaping @MainActor (FavoritesStationEvent) -> Void) {
        observers.add(owner: owner, handler)
    }

    private func credentials() async throws -> (uid: String, token: String) {
        guard let uid = service.currentAccount?.id else { throw AuthError.unauthorized }
        return (uid, try await service.idToken())
    }

    private func notify() {
        observers.notify(.needUpdate)
    }
}
