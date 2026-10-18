//
//  Builders.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
@testable import Zaryad

// MARK: - Coordinates -
let lviv = Coordinate(latitude: 49.8397, longitude: 24.0297)
// MARK: - Stations -
@MainActor
func makeStation(
    id: Int,
    latitude: Double = 50.4501,
    longitude: Double = 30.5234,
    powerKW: Int? = 50,
    isOperational: Bool = true
) -> ChargingStation {
    ChargingStation(
        id: id,
        uuid: "uuid-\(id)",
        addressInfo: .init(
            title: "Станція \(id)", addressLine1: "вул. Тестова, \(id)", town: "Київ", postcode: nil,
            country: .init(isoCode: "UA", title: "Ukraine"), latitude: latitude, longitude: longitude,
            contactTelephone1: nil, distance: nil, distanceUnit: nil
        ),
        operatorInfo: .init(id: 1, title: "Оператор", websiteURL: nil),
        usageType: nil,
        statusType: .init(id: 50, title: "Operational", isOperational: isOperational),
        connections: [
            .init(
                id: 1, connectionType: .init(id: 33, title: "CCS (Type 2)", formalName: nil),
                currentType: nil, level: nil, powerKW: powerKW, quantity: 2, amps: nil, voltage: nil
            )
        ],
        numberOfPoints: 2,
        generalComments: nil,
        dateLastVerified: nil
    )
}
// MARK: - MapVM -
@MainActor
func makeMapVM(
    repo: StationsRepositorySpy? = nil,
    location: Coordinate? = nil
) -> MapVM {
    MapVM(repo: repo ?? StationsRepositorySpy(), locationService: LocationServiceStub(location: location))
}
// MARK: - Async -
@MainActor
func settle() async {
    for _ in 0..<20 { await Task.yield() }
}
// MARK: - DTO -
func makeFavoriteDTO(id: Int = 42, rate: Int = 4, note: String? = "нотатка", addedAt: Double? = 1_700_000_000.5) -> FavoriteStationDTO {
    FavoriteStationDTO(
        station: OCMStationDTO(
            id: id, uuid: "uuid-\(id)",
            addressInfo: .init(
                title: "Тест", addressLine1: "вул. 1", town: "Київ", postcode: nil,
                country: .init(isoCode: "UA", title: "Ukraine"), latitude: 50.45, longitude: 30.52,
                contactTelephone1: nil, distance: nil, distanceUnit: 2
            ),
            operatorInfo: nil,
            usageType: .init(id: 1, title: "Public", isPayAtLocation: true),
            statusType: .init(id: 50, title: "Operational", isOperational: true),
            connections: [
                .init(
                    id: 1, connectionType: .init(id: 33, title: "CCS", formalName: nil), currentType: nil, level: nil,
                    powerKW: 150, quantity: 2, amps: 200, voltage: 400.5
                )
            ],
            numberOfPoints: 2, generalComments: nil, dateLastVerified: "2025-11-03T10:15:00Z", mediaItems: []
        ),
        rate: rate,
        note: note,
        addedAt: addedAt
    )
}
