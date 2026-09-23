//
//  ChargingStation.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import Foundation

// MARK: - ChargingStation
struct ChargingStation: Sendable {
    let id: Int?
    let uuid: String?
    let addressInfo: AddressInfo?
    let operatorInfo: OperatorInfo?
    let usageType: UsageType?
    let statusType: StatusType?
    let connections: [Connection]?
    let numberOfPoints: Int?
    let generalComments: String?
    let dateLastVerified: Date?
}

// MARK: - AddressInfo
extension ChargingStation {
    struct AddressInfo: Sendable {
        let title: String?
        let addressLine1: String?
        let town: String?
        let postcode: String?
        let country: Country?
        let latitude: Double?
        let longitude: Double?
        let contactTelephone1: String?
        let distance: Double?
        let distanceUnit: Int?
    }
}

// MARK: - Connection
extension ChargingStation {
    struct Connection: Sendable {
        let id: Int?
        let connectionType: ConnectionType?
        let currentType: DataProvider?
        let level: Level?
        let powerKW: Int?
        let quantity: Int?
        let amps: Int?
        let voltage: Int?
    }
}

// MARK: - OperatorInfo
extension ChargingStation {
    struct OperatorInfo: Sendable {
        let id: Int?
        let title: String?
        let websiteURL: String?
    }
}

// MARK: - StatusType
extension ChargingStation {
    struct StatusType: Sendable {
        let id: Int?
        let title: String?
        let isOperational: Bool?
    }
}

// MARK: - UsageType
extension ChargingStation {
    struct UsageType: Sendable {
        let id: Int?
        let title: String?
        let isPayAtLocation: Bool?
    }
}

// MARK: - Country
extension ChargingStation.AddressInfo {
    struct Country: Sendable {
        let isoCode: String?
        let title: String?
    }
}

// MARK: - ConnectionType
extension ChargingStation.Connection {
    struct ConnectionType: Sendable {
        let id: Int?
        let title: String?
        let formalName: String?
    }
}

// MARK: - DataProvider
extension ChargingStation.Connection {
    struct DataProvider: Sendable {
        let id: Int?
        let title: String?
    }
}

// MARK: - Level
extension ChargingStation.Connection {
    struct Level: Sendable {
        let id: Int?
        let title: String?
        let isFastChargeCapable: Bool?
    }
}
