//
//  MapStationUIModel.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct MapStationUIModel: Identifiable, Equatable {
    let id: Int
    let name: String
    let address: String
    let coordinate: Coordinate
    let power: PowerTier
    let powerKW: Int?
    let connectorsText: String
    let operatorName: String?
    let isOperational: Bool
}
