//
//  StationDetailsUIMapper.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct StationDetailsUIMapper {
    func map(_ station: ChargingStation) -> StationDetailsUIModel {
        let address = [station.addressInfo?.addressLine1, station.addressInfo?.town, station.addressInfo?.postcode]
            .compactMap { $0 }
            .joined(separator: ", ")

        let isOperational = station.statusType?.isOperational ?? false
        let maxPowerKW = station.connections?.compactMap { $0.powerKW }.max()

        let usage = station.usageType.map { usage in
            [usage.title, usage.isPayAtLocation == true ? "оплата на місці" : nil]
                .compactMap { $0 }
                .joined(separator: " · ")
        }

        return StationDetailsUIModel(
            id: station.id,
            name: station.addressInfo?.title ?? "Без назви",
            address: address,
            coordinate: station.coordinate ?? .kyiv,
            operatorName: station.operatorInfo?.title,
            isOperational: isOperational,
            statusText: isOperational ? "Працює" : (station.statusType?.title ?? "Статус невідомий"),
            usageText: usage,
            power: PowerTier(kW: maxPowerKW),
            powerKW: maxPowerKW,
            pointsCount: station.numberOfPoints,
            connectors: (station.connections ?? []).map(map),
            description: station.generalComments,
            phone: station.addressInfo?.contactTelephone1,
            website: station.operatorInfo?.websiteURL.flatMap(URL.init(string:)),
            photos: (station.mediaItems ?? []).compactMap(map),
            lastVerifiedText: station.dateLastVerified?.formatted(
                .dateTime.day().month(.wide).year().locale(Locale(identifier: "uk_UA"))
            )
        )
    }

    private func map(_ connection: ChargingStation.Connection) -> StationDetailsUIModel.Connector {
        let details = [
            connection.voltage.map { "\($0) В" },
            connection.amps.map { "\($0) А" }
        ].compactMap { $0 }

        return StationDetailsUIModel.Connector(
            id: UUID(),
            title: connection.connectionType?.title ?? "Невідомий роз'єм",
            powerText: connection.powerKW.map { "\($0) кВт" } ?? "—",
            currentText: ([connection.currentType?.title].compactMap { $0 } + details).joined(separator: " · "),
            quantity: connection.quantity,
            isFast: connection.level?.isFastChargeCapable ?? false
        )
    }

    private func map(_ item: ChargingStation.MediaItem) -> StationDetailsUIModel.Photo? {
        guard let url = (item.itemURL ?? item.itemThumbnailURL).flatMap(URL.init(string:)) else { return nil }
        return StationDetailsUIModel.Photo(id: UUID(), url: url, comment: item.comment)
    }
}
