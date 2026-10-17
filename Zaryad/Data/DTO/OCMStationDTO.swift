//
//  OCMStationDTO.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// POI з Open Charge Map (`GET /v3/poi`). З `verbose=false` порожні поля не приходять — тому все опціональне.
/// `Encodable` — бо в такому ж форматі станція зберігається в обраному (Firebase).
nonisolated struct OCMStationDTO: Codable, Sendable {
    let id: Int?
    let uuid: String?
    let addressInfo: AddressInfo?
    let operatorInfo: OperatorInfo?
    let usageType: UsageType?
    let statusType: StatusType?
    let connections: [Connection]?
    let numberOfPoints: Int?
    let generalComments: String?
    let dateLastVerified: String?
    let mediaItems: [MediaItem]?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case uuid = "UUID"
        case addressInfo = "AddressInfo"
        case operatorInfo = "OperatorInfo"
        case usageType = "UsageType"
        case statusType = "StatusType"
        case connections = "Connections"
        case numberOfPoints = "NumberOfPoints"
        case generalComments = "GeneralComments"
        case dateLastVerified = "DateLastVerified"
        case mediaItems = "MediaItems"
    }
}

// MARK: - AddressInfo
extension OCMStationDTO {
    nonisolated struct AddressInfo: Codable, Sendable {
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

        enum CodingKeys: String, CodingKey {
            case title = "Title"
            case addressLine1 = "AddressLine1"
            case town = "Town"
            case postcode = "Postcode"
            case country = "Country"
            case latitude = "Latitude"
            case longitude = "Longitude"
            case contactTelephone1 = "ContactTelephone1"
            case distance = "Distance"
            case distanceUnit = "DistanceUnit"
        }
    }

    nonisolated struct Country: Codable, Sendable {
        let isoCode: String?
        let title: String?

        enum CodingKeys: String, CodingKey {
            case isoCode = "ISOCode"
            case title = "Title"
        }
    }
}

// MARK: - OperatorInfo / UsageType / StatusType
extension OCMStationDTO {
    nonisolated struct OperatorInfo: Codable, Sendable {
        let id: Int?
        let title: String?
        let websiteURL: String?

        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case title = "Title"
            case websiteURL = "WebsiteURL"
        }
    }

    nonisolated struct UsageType: Codable, Sendable {
        let id: Int?
        let title: String?
        let isPayAtLocation: Bool?

        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case title = "Title"
            case isPayAtLocation = "IsPayAtLocation"
        }
    }

    nonisolated struct StatusType: Codable, Sendable {
        let id: Int?
        let title: String?
        let isOperational: Bool?

        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case title = "Title"
            case isOperational = "IsOperational"
        }
    }
}

// MARK: - Connection
extension OCMStationDTO {
    nonisolated struct Connection: Codable, Sendable {
        let id: Int?
        let connectionType: Reference?
        let currentType: Reference?
        let level: Level?
        let powerKW: Double?
        let quantity: Int?
        let amps: Double?
        let voltage: Double?

        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case connectionType = "ConnectionType"
            case currentType = "CurrentType"
            case level = "Level"
            case powerKW = "PowerKW"
            case quantity = "Quantity"
            case amps = "Amps"
            case voltage = "Voltage"
        }
    }

    /// Довідкові об'єкти OCM (`ConnectionType`, `CurrentType`): ID + назва.
    nonisolated struct Reference: Codable, Sendable {
        let id: Int?
        let title: String?
        let formalName: String?

        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case title = "Title"
            case formalName = "FormalName"
        }
    }

    nonisolated struct Level: Codable, Sendable {
        let id: Int?
        let title: String?
        let isFastChargeCapable: Bool?

        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case title = "Title"
            case isFastChargeCapable = "IsFastChargeCapable"
        }
    }
}

// MARK: - MediaItem
extension OCMStationDTO {
    nonisolated struct MediaItem: Codable, Sendable {
        let id: Int?
        let itemURL: String?
        let itemThumbnailURL: String?
        let comment: String?

        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case itemURL = "ItemURL"
            case itemThumbnailURL = "ItemThumbnailURL"
            case comment = "Comment"
        }
    }
}
