//
//  MapStationUIMapper.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct MapStationUIMapper {
    func map(_ station: ChargingStation, from center: Coordinate) -> MapStationUIModel? {
        guard let coordinate = station.coordinate else { return nil }

        let address = [station.addressInfo?.addressLine1, station.addressInfo?.town]
            .compactMap { $0 }
            .joined(separator: ", ")

        var seen = Set<String>()
        let connectors = (station.connections ?? [])
            .compactMap { $0.connectionType?.title }
            .filter { seen.insert($0).inserted }

        let maxPowerKW = station.connections?.compactMap { $0.powerKW }.max()

        return MapStationUIModel(
            id: station.id,
            name: station.addressInfo?.title ?? "Без назви",
            address: address,
            coordinate: coordinate,
            power: PowerTier(kW: maxPowerKW),
            powerKW: maxPowerKW,
            connectorsText: connectors.joined(separator: ", "),
            operatorName: station.operatorInfo?.title,
            isOperational: station.statusType?.isOperational ?? false,
            distanceKm: coordinate.distance(to: center)
        )
    }
    func map(_ stations: [ChargingStation], from center: Coordinate) -> [MapStationUIModel] {
        stations
            .compactMap { map($0, from: center) }
            .sorted { $0.distanceKm < $1.distanceKm }
    }
}
