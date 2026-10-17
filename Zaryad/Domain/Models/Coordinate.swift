//
//  Coordinate.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct Coordinate: Sendable, Equatable {
    let latitude: Double
    let longitude: Double
}

extension Coordinate {
    static let kyiv = Coordinate(latitude: 50.4501, longitude: 30.5234)

    func distance(to other: Coordinate) -> Double {
        let earthRadiusKm = 6371.0
        let dLat = (other.latitude - latitude) * .pi / 180
        let dLon = (other.longitude - longitude) * .pi / 180
        let lat1 = latitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) + sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2)
        return earthRadiusKm * 2 * atan2(sqrt(a), sqrt(1 - a))
    }
}

extension ChargingStation {
    var coordinate: Coordinate? {
        guard let lat = addressInfo?.latitude, let lon = addressInfo?.longitude else { return nil }
        return Coordinate(latitude: lat, longitude: lon)
    }
}
