//
//  MockStationsRepository.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// TEMP / DEMO: in-memory репозиторій станцій.
/// Заміниться реальним (Open Charge Map, GET /v3/poi) на етапі мережі (лаб 4).
final class MockStationsRepository: PStationsRepository, Sendable {

    private let stations: [ChargingStation]

    init(stations: [ChargingStation] = MockStationsRepository.mockStations) {
        self.stations = stations
    }

    func stations(near: Coordinate, radius: Double) async throws -> [ChargingStation] {
        try await Task.sleep(for: .seconds(0.5))
        return stations.filter {
            guard let coordinate = $0.coordinate else { return false }
            return coordinate.distance(to: near) <= radius
        }
    }
}

// MARK: - Mock data

private extension MockStationsRepository {

    static let mockStations: [ChargingStation] = [
        station(id: 1, name: "EcoCharge Хрещатик", address: "вул. Хрещатик, 22",
                lat: 50.4501, lon: 30.5234, powerKW: 180, connector: (33, "CCS (Type 2)"),
                operatorName: "EcoCharge", isOperational: true,
                comments: "Підземний паркінг ТЦ, рівень -2. Перші 2 години паркування безкоштовні під час зарядки.",
                phone: "+380 44 000 00 01", website: "https://ecocharge.example"),
        station(id: 2, name: "YASNO · Арена", address: "пр. Науки, 5",
                lat: 50.4110, lon: 30.5290, powerKW: 120, connector: (33, "CCS (Type 2)"),
                operatorName: "YASNO E", isOperational: true,
                comments: "Біля входу на арену. Цілодобово, оплата в застосунку YASNO E."),
        station(id: 3, name: "GO TO-U · Поділ", address: "вул. Сагайдачного, 10",
                lat: 50.4650, lon: 30.5150, powerKW: 60, connector: (25, "Type 2"),
                operatorName: "GO TO-U", isOperational: true),
        station(id: 4, name: "City Charge · Оболонь", address: "пр. Оболонський, 1",
                lat: 50.5010, lon: 30.4980, powerKW: 22, connector: (25, "Type 2"),
                operatorName: "City Charge", isOperational: false,
                comments: "Тимчасово не працює: заміна обладнання."),
        station(id: 5, name: "Tesla Supercharger · Лук'янівка", address: "вул. Мельникова, 12",
                lat: 50.4620, lon: 30.4780, powerKW: 250, connector: (27, "Tesla"),
                operatorName: "Tesla", isOperational: true,
                comments: "Для авто інших марок — через застосунок Tesla.", website: "https://tesla.com"),
        station(id: 6, name: "AutoEnterprise · Позняки", address: "вул. Драгоманова, 31",
                lat: 50.3990, lon: 30.6340, powerKW: 50, connector: (2, "CHAdeMO"),
                operatorName: "AutoEnterprise", isOperational: true),
        station(id: 7, name: "EcoCharge · Ocean Plaza", address: "вул. Антоновича, 176",
                lat: 50.4120, lon: 30.5220, powerKW: 22, connector: (25, "Type 2"),
                operatorName: "EcoCharge", isOperational: true),
        station(id: 8, name: "YASNO · ВДНГ", address: "пр. Академіка Глушкова, 1",
                lat: 50.3820, lon: 30.4770, powerKW: 150, connector: (33, "CCS (Type 2)"),
                operatorName: "YASNO E", isOperational: true),
        station(id: 9, name: "TOKA · Троєщина", address: "вул. Маяковського, 26",
                lat: 50.5150, lon: 30.6030, powerKW: 60, connector: (33, "CCS (Type 2)"),
                operatorName: "TOKA", isOperational: false),
        station(id: 10, name: "GO TO-U · Бровари", address: "бул. Незалежності, 4",
                lat: 50.5110, lon: 30.7900, powerKW: 100, connector: (33, "CCS (Type 2)"),
                operatorName: "GO TO-U", isOperational: true),
    ]

    static func station(
        id: Int, name: String, address: String,
        lat: Double, lon: Double, powerKW: Int,
        connector: (id: Int, title: String), operatorName: String, isOperational: Bool,
        comments: String? = nil, phone: String? = nil, website: String? = nil
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
                contactTelephone1: phone,
                distance: nil,
                distanceUnit: 2
            ),
            operatorInfo: .init(id: nil, title: operatorName, websiteURL: website),
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
                    currentType: .init(id: 30, title: powerKW >= 50 ? "DC" : "AC"),
                    level: .init(id: 3, title: "Level 3", isFastChargeCapable: powerKW >= 50),
                    powerKW: powerKW,
                    quantity: 2,
                    amps: 200,
                    voltage: 400
                )
            ],
            numberOfPoints: 2,
            generalComments: comments,
            dateLastVerified: Date()
        )
    }
}
