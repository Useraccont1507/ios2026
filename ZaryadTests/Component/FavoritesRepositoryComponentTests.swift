//
//  FavoritesRepositoryComponentTests.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
import Testing
@testable import Zaryad

/// Ланцюжок FirebaseFavoritesRepository → FirestoreEndpoint/FirestoreCoder → RequestManager → URLSession.
@MainActor
@Suite("Компонент: обране (Firestore REST)")
struct FavoritesRepositoryComponentTests {
    // MARK: - load -
    @Test("Завантаження → GET users/{uid}/favorites з Bearer-токеном, документи → обране (FR-8)")
    func loadFavorites_ok_getsUserCollection() async throws {
        let host = uniqueHost()
        let body = try collectionJSON([makeFavoriteDTO(id: 5, rate: 3)])
        let repo = makeRepository(host: host) { (.stub($0.url, status: 200), body) }
        let favorites = try await repo.loadFavorites(forced: true)
        #expect(favorites.map(\.station.id) == [5])
        #expect(favorites.first?.rate == 3)
        let request = try #require(StubURLProtocol.recordedRequests(host: host).first)
        #expect(request.httpMethod == "GET")
        #expect(request.url?.path().hasSuffix("/users/uid-1/favorites") == true)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-id-token")
    }
    @Test("Гість → без запиту, порожній список (FR-16)")
    func loadFavorites_guest_noRequest() async throws {
        let host = uniqueHost()
        let repo = makeRepository(host: host, account: nil) { (.stub($0.url, status: 200), Data("{}".utf8)) }
        #expect(try await repo.loadFavorites(forced: true).isEmpty)
        #expect(StubURLProtocol.recordedRequests(host: host).isEmpty)
    }
    // MARK: - create / delete -
    @Test("Додавання → PATCH users/{uid}/favorites/{id} з полями Firestore (FR-6, FR-7)")
    func createFavorite_sendsPatchWithFields() async throws {
        let host = uniqueHost()
        let repo = makeRepository(host: host) { (.stub($0.url, status: 200), Data("{}".utf8)) }
        let station = makeStation(id: 77)
        try await repo.createFavorite(station: FavoriteStation(station: station, rate: 4, note: nil))
        let request = try #require(StubURLProtocol.recordedRequests(host: host).first)
        #expect(request.httpMethod == "PATCH")
        #expect(request.url?.path().hasSuffix("/users/uid-1/favorites/77") == true)
        let json = try JSONSerialization.jsonObject(with: try #require(request.httpBody)) as? [String: Any]
        let fields = try #require(json?["fields"] as? [String: Any])
        #expect(fields["rate"] as? [String: String] == ["integerValue": "4"])
    }
    @Test("Видалення → DELETE users/{uid}/favorites/{id} (FR-9)")
    func removeFavorite_sendsDelete() async throws {
        let host = uniqueHost()
        let repo = makeRepository(host: host) { (.stub($0.url, status: 200), Data("{}".utf8)) }
        try await repo.removeFavorite(station: FavoriteStation(station: makeStation(id: 77), rate: 4, note: nil))
        let request = try #require(StubURLProtocol.recordedRequests(host: host).first)
        #expect(request.httpMethod == "DELETE")
        #expect(request.url?.path().hasSuffix("/users/uid-1/favorites/77") == true)
    }
    @Test("Правила Firestore відхилили запис (403) → помилка, не тихий успіх (NFR-5)")
    func createFavorite_forbidden_throws() async {
        let repo = makeRepository(host: uniqueHost()) { (.stub($0.url, status: 403), Data()) }
        await #expect(throws: NetworkError.self) {
            try await repo.createFavorite(station: FavoriteStation(station: makeStation(id: 1), rate: 5, note: nil))
        }
    }
    // MARK: - Helpers -
    private func makeRepository(
        host: String,
        account: Account? = makeAccount(),
        handler: @escaping StubURLProtocol.Handler
    ) -> FirebaseFavoritesRepository {
        let manager = RequestManager(
            baseURL: URL(string: "https://\(host)/v1/projects/zaryad-test/databases/(default)/documents")!,
            session: StubURLProtocol.session(host: host, handler: handler),
            toastPresenter: ToastPresenterSpy()
        )
        return FirebaseFavoritesRepository(
            service: FirebaseServiceStub(account: account),
            authRepo: AuthRepositorySpy(),
            requestManager: manager
        )
    }
    private func collectionJSON(_ favorites: [FavoriteStationDTO]) throws -> Data {
        let documents = try favorites.map { favorite -> [String: Any] in
            let body = try JSONSerialization.jsonObject(with: FirestoreCoder.documentBody(favorite)) as? [String: Any] ?? [:]
            return ["name": "doc", "fields": body["fields"] ?? [:]]
        }
        return try JSONSerialization.data(withJSONObject: ["documents": documents])
    }
}
