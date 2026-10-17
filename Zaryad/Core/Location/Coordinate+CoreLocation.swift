//
//  Coordinate+CoreLocation.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import CoreLocation

extension Coordinate {
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D {
    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
}
