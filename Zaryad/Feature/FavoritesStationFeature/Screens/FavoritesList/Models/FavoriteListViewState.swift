//
//  FavoriteListViewState.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import Foundation

enum FavoriteListViewState {
    case loading, empty, error, list(stations: [FavoriteStationUIModel])
}
