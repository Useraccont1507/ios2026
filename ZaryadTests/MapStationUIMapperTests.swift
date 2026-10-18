//
//  MapStationUIMapperTests.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
import Testing
@testable import Zaryad

@MainActor
@Suite("MapStationUIMapper")
struct MapStationUIMapperTests {
    // MARK: - map -
    @Test("Станція без координат не потрапляє на карту")
    func map_missingCoordinate_returnsNil() {
        let station = makeStation(id: 1)
        let noCoordinates = ChargingStation(
            id: 2, uuid: nil, addressInfo: nil, operatorInfo: nil, usageType: nil, statusType: nil,
            connections: nil, numberOfPoints: nil, generalComments: nil, dateLastVerified: nil
        )
        let result = MapStationUIMapper().map([station, noCoordinates], from: .kyiv)
        #expect(result.map(\.id) == [1])
    }
    @Test("Категорія потужності береться з максимального роз'єму", arguments: [
        (22, PowerTier.slow), (50, .fast), (120, .high), (180, .ultra)
    ])
    func map_maxPower_definesTier(powerKW: Int, tier: PowerTier) throws {
        let model = try #require(MapStationUIMapper().map(makeStation(id: 1, powerKW: powerKW), from: .kyiv))
        #expect(model.power == tier)
        #expect(model.powerKW == powerKW)
    }
    @Test("Відстань рахується від центру пошуку, у км")
    func map_distance_fromSearchCenter() throws {
        let model = try #require(MapStationUIMapper().map(makeStation(id: 1, latitude: 50.4501, longitude: 30.5234), from: .kyiv))
        #expect(model.distanceKm < 0.01)
        let far = try #require(MapStationUIMapper().map(makeStation(id: 2), from: lviv))
        #expect(far.distanceKm > 400 && far.distanceKm < 500)
    }
}
