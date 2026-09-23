//
//  FavoriteStationUIMapper.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import Foundation

struct FavoriteStationUIMapper {
    func map(_ favorite: FavoriteStation) -> FavoriteStationUIModel {
        let station = favorite.station

        let address = [station.addressInfo?.addressLine1, station.addressInfo?.town]
            .compactMap { $0 }
            .joined(separator: ", ")

        var seen = Set<String>()
        let connectors = (station.connections ?? [])
            .compactMap { $0.connectionType?.title }
            .filter { seen.insert($0).inserted }

        let maxPowerKW = station.connections?.compactMap { $0.powerKW }.max()

        return FavoriteStationUIModel(
            id: station.id,
            name: station.addressInfo?.title ?? "Без назви",
            address: address,
            power: PowerTier(kW: maxPowerKW),
            connectorsText: connectors.joined(separator: ", "),
            rate: favorite.rate,
            note: favorite.note,
            needToDelete: false
        )
    }
    func map(_ favorites: [FavoriteStation]) -> [FavoriteStationUIModel] {
        favorites.map(map)
    }
}
