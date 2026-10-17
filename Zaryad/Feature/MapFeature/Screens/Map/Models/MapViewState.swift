//
//  MapViewState.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

enum MapViewState {
    case loading, empty, error, loaded(stations: [MapStationUIModel])
}
