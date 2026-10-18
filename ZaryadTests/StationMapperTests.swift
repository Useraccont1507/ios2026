//
//  StationMapperTests.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
import Testing
@testable import Zaryad

@MainActor
@Suite("StationMapper")
struct StationMapperTests {
    // MARK: - map -
    @Test("POI без ID відкидається — його не можна показати чи зберегти")
    func map_missingId_returnsNil() {
        #expect(StationMapper().map(makeOCMDTO(id: nil)) == nil)
    }
    @Test("Дробова потужність округлюється до цілих кВт")
    func map_fractionalPower_isRounded() throws {
        let station = try #require(StationMapper().map(makeOCMDTO(powers: [150.4, 7.6], connectors: ["CCS", "Type 2"])))
        #expect(station.connections?.compactMap(\.powerKW) == [150, 8])
    }
    @Test("Дата перевірки з мілісекундами і без — обидві розбираються")
    func map_dateFormats_bothParsed() {
        let mapper = StationMapper()
        #expect(mapper.map(makeOCMDTO(dateLastVerified: "2025-11-03T10:15:00Z"))?.dateLastVerified != nil)
        #expect(mapper.map(makeOCMDTO(dateLastVerified: "2024-01-02T03:04:05.678Z"))?.dateLastVerified != nil)
        #expect(mapper.map(makeOCMDTO(dateLastVerified: "not a date"))?.dateLastVerified == nil)
    }
    @Test("Масив DTO → лише станції з ID, порядок збережено")
    func mapArray_skipsInvalid_keepsOrder() {
        let stations = StationMapper().map([makeOCMDTO(id: 3), makeOCMDTO(id: nil), makeOCMDTO(id: 1)])
        #expect(stations.map(\.id) == [3, 1])
    }
    // MARK: - dto(from:) -
    @Test("Домен → DTO → домен зберігає ID, координати й потужність (запис в обране)")
    func dto_roundTrip_preservesKeyFields() throws {
        let mapper = StationMapper()
        let original = try #require(mapper.map(makeOCMDTO(id: 9, latitude: 49.84, longitude: 24.03, powers: [120])))
        let restored = try #require(mapper.map(mapper.dto(from: original)))
        #expect(restored.id == 9)
        #expect(restored.coordinate == Coordinate(latitude: 49.84, longitude: 24.03))
        #expect(restored.connections?.first?.powerKW == 120)
    }
}
