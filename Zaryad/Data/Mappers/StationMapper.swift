//
//  StationMapper.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct StationMapper {
    /// `nil`, якщо в POI немає ID — без нього станцію не можна ні показати, ні додати в обране.
    func map(_ dto: OCMStationDTO) -> ChargingStation? {
        guard let id = dto.id else { return nil }
        return ChargingStation(
            id: id,
            uuid: dto.uuid,
            addressInfo: dto.addressInfo.map(map),
            operatorInfo: dto.operatorInfo.map {
                .init(id: $0.id, title: $0.title, websiteURL: $0.websiteURL)
            },
            usageType: dto.usageType.map {
                .init(id: $0.id, title: $0.title, isPayAtLocation: $0.isPayAtLocation)
            },
            statusType: dto.statusType.map {
                .init(id: $0.id, title: $0.title, isOperational: $0.isOperational)
            },
            connections: dto.connections?.map(map),
            numberOfPoints: dto.numberOfPoints,
            generalComments: dto.generalComments,
            dateLastVerified: dto.dateLastVerified.flatMap(Self.date(from:)),
            mediaItems: dto.mediaItems?.map {
                .init(id: $0.id, itemURL: $0.itemURL, itemThumbnailURL: $0.itemThumbnailURL, comment: $0.comment)
            }
        )
    }

    func map(_ dtos: [OCMStationDTO]) -> [ChargingStation] {
        dtos.compactMap(map)
    }

    private func map(_ dto: OCMStationDTO.AddressInfo) -> ChargingStation.AddressInfo {
        ChargingStation.AddressInfo(
            title: dto.title,
            addressLine1: dto.addressLine1,
            town: dto.town,
            postcode: dto.postcode,
            country: dto.country.map { .init(isoCode: $0.isoCode, title: $0.title) },
            latitude: dto.latitude,
            longitude: dto.longitude,
            contactTelephone1: dto.contactTelephone1,
            distance: dto.distance,
            distanceUnit: dto.distanceUnit
        )
    }

    private func map(_ dto: OCMStationDTO.Connection) -> ChargingStation.Connection {
        ChargingStation.Connection(
            id: dto.id,
            connectionType: dto.connectionType.map {
                .init(id: $0.id, title: $0.title, formalName: $0.formalName)
            },
            currentType: dto.currentType.map { .init(id: $0.id, title: $0.title) },
            level: dto.level.map {
                .init(id: $0.id, title: $0.title, isFastChargeCapable: $0.isFastChargeCapable)
            },
            powerKW: dto.powerKW.map { Int($0.rounded()) },
            quantity: dto.quantity,
            amps: dto.amps.map { Int($0.rounded()) },
            voltage: dto.voltage.map { Int($0.rounded()) }
        )
    }

    // MARK: - Domain → DTO (для збереження в обраному)
    func dto(from station: ChargingStation) -> OCMStationDTO {
        OCMStationDTO(
            id: station.id,
            uuid: station.uuid,
            addressInfo: station.addressInfo.map {
                .init(
                    title: $0.title, addressLine1: $0.addressLine1, town: $0.town, postcode: $0.postcode,
                    country: $0.country.map { .init(isoCode: $0.isoCode, title: $0.title) },
                    latitude: $0.latitude, longitude: $0.longitude, contactTelephone1: $0.contactTelephone1,
                    distance: $0.distance, distanceUnit: $0.distanceUnit
                )
            },
            operatorInfo: station.operatorInfo.map { .init(id: $0.id, title: $0.title, websiteURL: $0.websiteURL) },
            usageType: station.usageType.map { .init(id: $0.id, title: $0.title, isPayAtLocation: $0.isPayAtLocation) },
            statusType: station.statusType.map { .init(id: $0.id, title: $0.title, isOperational: $0.isOperational) },
            connections: station.connections?.map {
                .init(
                    id: $0.id,
                    connectionType: $0.connectionType.map { .init(id: $0.id, title: $0.title, formalName: $0.formalName) },
                    currentType: $0.currentType.map { .init(id: $0.id, title: $0.title, formalName: nil) },
                    level: $0.level.map { .init(id: $0.id, title: $0.title, isFastChargeCapable: $0.isFastChargeCapable) },
                    powerKW: $0.powerKW.map(Double.init),
                    quantity: $0.quantity,
                    amps: $0.amps.map(Double.init),
                    voltage: $0.voltage.map(Double.init)
                )
            },
            numberOfPoints: station.numberOfPoints,
            generalComments: station.generalComments,
            dateLastVerified: station.dateLastVerified.map { ISO8601DateFormatter().string(from: $0) },
            mediaItems: station.mediaItems?.map {
                .init(id: $0.id, itemURL: $0.itemURL, itemThumbnailURL: $0.itemThumbnailURL, comment: $0.comment)
            }
        )
    }

    /// OCM віддає дати то з мілісекундами, то без.
    nonisolated private static func date(from string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
}
