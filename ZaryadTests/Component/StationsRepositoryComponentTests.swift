//
//  StationsRepositoryComponentTests.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
import Testing
@testable import Zaryad

/// Ланцюжок StationsRepository → OCMEndpoint → RequestManager → URLSession, мережа замінена URLProtocol.
@MainActor
@Suite("Компонент: пошук станцій (Open Charge Map)")
struct StationsRepositoryComponentTests {
    // MARK: - 200 -
    @Test("200 + JSON OCM → доменні станції; запит має шлях, параметри й ключ API (FR-1)")
    func stations_ok_mapsResponseAndBuildsRequest() async throws {
        let host = uniqueHost()
        let (repo, toasts) = makeRepository(host: host) { request in
            (.stub(request.url, status: 200), Data(Self.ocmJSON.utf8))
        }
        let stations = try await repo.stations(near: .kyiv, radius: 5)
        #expect(stations.map(\.id) == [101, 102])
        #expect(stations.first?.connections?.first?.powerKW == 150)
        #expect(toasts.messages.isEmpty)
        let request = try #require(StubURLProtocol.recordedRequests(host: host).first)
        let items = Dictionary(uniqueKeysWithValues: (URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        #expect(request.httpMethod == "GET")
        #expect(request.url?.path() == "/v3/poi")
        #expect(items["latitude"] == "50.4501" && items["longitude"] == "30.5234")
        #expect(items["distance"] == "5.0" && items["distanceunit"] == "km")
        #expect(items["maxresults"] == "100" && items["output"] == "json")
        #expect(request.value(forHTTPHeaderField: "X-API-Key") == OCMConfig.apiKey)
    }
    @Test("200 з порожнім масивом → порожній результат (NFR-4)")
    func stations_emptyArray_returnsEmpty() async throws {
        let (repo, _) = makeRepository(host: uniqueHost()) { (.stub($0.url, status: 200), Data("[]".utf8)) }
        #expect(try await repo.stations(near: .kyiv, radius: 5).isEmpty)
    }
    // MARK: - errors (NFR-3) -
    @Test("403 → NetworkError.http(403) і тост «Немає доступу»")
    func stations_forbidden_httpErrorAndToast() async {
        let (repo, toasts) = makeRepository(host: uniqueHost()) { (.stub($0.url, status: 403), Data()) }
        await #expect {
            _ = try await repo.stations(near: .kyiv, radius: 5)
        } throws: { error in
            guard case .http(let response) = error as? NetworkError else { return false }
            return response.statusCode == 403
        }
        #expect(toasts.messages == ["Немає доступу"])
    }
    @Test("Немає мережі → NetworkError.transport і тост про з'єднання")
    func stations_offline_transportErrorAndToast() async {
        let (repo, toasts) = makeRepository(host: uniqueHost()) { _ in throw URLError(.notConnectedToInternet) }
        await #expect {
            _ = try await repo.stations(near: .kyiv, radius: 5)
        } throws: { error in
            guard case .transport = error as? NetworkError else { return false }
            return true
        }
        #expect(toasts.messages == ["Немає з'єднання з інтернетом"])
    }
    @Test("Битий JSON → NetworkError.decoding")
    func stations_brokenJSON_decodingError() async {
        let (repo, _) = makeRepository(host: uniqueHost()) { (.stub($0.url, status: 200), Data("{\"oops\":".utf8)) }
        await #expect {
            _ = try await repo.stations(near: .kyiv, radius: 5)
        } throws: { error in
            guard case .decoding = error as? NetworkError else { return false }
            return true
        }
    }
    // MARK: - Helpers -
    private func makeRepository(
        host: String,
        handler: @escaping StubURLProtocol.Handler
    ) -> (StationsRepository, ToastPresenterSpy) {
        let toasts = ToastPresenterSpy()
        let manager = RequestManager(
            baseURL: URL(string: "https://\(host)/v3")!,
            session: StubURLProtocol.session(host: host, handler: handler),
            toastPresenter: toasts
        )
        return (StationsRepository(requestManager: manager), toasts)
    }
    private static let ocmJSON = """
    [
      {"ID": 101, "AddressInfo": {"Title": "A", "Latitude": 50.45, "Longitude": 30.52},
       "StatusType": {"ID": 50, "IsOperational": true},
       "Connections": [{"ConnectionType": {"ID": 33, "Title": "CCS (Type 2)"}, "PowerKW": 150.0, "Quantity": 2}],
       "DateLastVerified": "2025-11-03T10:15:00Z"},
      {"ID": 102, "AddressInfo": {"Title": "B", "Latitude": 50.46, "Longitude": 30.53}},
      {"AddressInfo": {"Title": "без ID"}}
    ]
    """
}
