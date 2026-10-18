//
//  FirestoreCoderTests.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
import Testing
@testable import Zaryad

@MainActor
@Suite("FirestoreCoder")
struct FirestoreCoderTests {
    // MARK: - documentBody -
    @Test("Цілі, дробові й булеві значення кодуються у відповідні типи Firestore")
    func documentBody_scalars_useFirestoreTypes() throws {
        let body = try FirestoreCoder.documentBody(makeFavoriteDTO(rate: 4, addedAt: 1_700_000_000.5))
        let fields = try #require(try fields(of: body))
        #expect(fields["rate"] as? [String: String] == ["integerValue": "4"])
        #expect(fields["addedAt"] as? [String: Double] == ["doubleValue": 1_700_000_000.5])
        let station = try #require((fields["station"] as? [String: Any])?["mapValue"] as? [String: Any])
        let stationFields = try #require(station["fields"] as? [String: Any])
        let status = try #require((stationFields["StatusType"] as? [String: Any])?["mapValue"] as? [String: Any])
        let operational = (status["fields"] as? [String: Any])?["IsOperational"] as? [String: Bool]
        #expect(operational == ["booleanValue": true])
    }
    // MARK: - round trip -
    @Test("Документ, закодований і повернутий як відповідь колекції, декодується без втрат")
    func roundTrip_favorite_preservesValues() throws {
        let original = makeFavoriteDTO(id: 42, rate: 5, note: "нотатка", addedAt: 1_700_000_000.5)
        let decoded = try FirestoreCoder.decodeDocuments(FavoriteStationDTO.self, from: collection(of: [original]))
        let favorite = try #require(decoded.first)
        #expect(decoded.count == 1)
        #expect(favorite.rate == 5)
        #expect(favorite.note == "нотатка")
        #expect(favorite.addedAt == 1_700_000_000.5)
        #expect(favorite.station.id == 42)
        #expect(favorite.station.statusType?.isOperational == true)
        #expect(favorite.station.connections?.first?.powerKW == 150)
        #expect(favorite.station.connections?.first?.voltage == 400.5)
        #expect(favorite.station.mediaItems?.isEmpty == true)
    }
    @Test("Відсутнє необов'язкове поле лишається nil після декодування")
    func roundTrip_nilNote_staysNil() throws {
        let decoded = try FirestoreCoder.decodeDocuments(
            FavoriteStationDTO.self,
            from: collection(of: [makeFavoriteDTO(note: nil)])
        )
        #expect(decoded.first?.note == nil)
    }
    // MARK: - decodeDocuments -
    @Test("Порожня колекція (відповідь без documents) → порожній список")
    func decodeDocuments_emptyCollection_returnsEmpty() throws {
        #expect(try FirestoreCoder.decodeDocuments(FavoriteStationDTO.self, from: Data("{}".utf8)).isEmpty)
        #expect(try FirestoreCoder.decodeDocuments(FavoriteStationDTO.self, from: nil).isEmpty)
    }
    // MARK: - Helpers -
    private func fields(of body: Data) throws -> [String: Any]? {
        (try JSONSerialization.jsonObject(with: body) as? [String: Any])?["fields"] as? [String: Any]
    }
    private func collection(of favorites: [FavoriteStationDTO]) throws -> Data {
        let documents = try favorites.map { favorite -> [String: Any] in
            let body = try FirestoreCoder.documentBody(favorite)
            let fields = try JSONSerialization.jsonObject(with: body) as? [String: Any] ?? [:]
            return ["name": "projects/p/databases/(default)/documents/users/u/favorites/\(favorite.station.id ?? 0)", "fields": fields["fields"] ?? [:]]
        }
        return try JSONSerialization.data(withJSONObject: ["documents": documents])
    }
}
