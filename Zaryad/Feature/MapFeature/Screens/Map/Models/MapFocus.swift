//
//  MapFocus.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct MapFocus: Equatable {
    let id = UUID()
    let coordinate: Coordinate
    let radius: Double
}
