//
//  StationFavoriteState.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

enum StationFavoriteState: Equatable {
    case loading
    case notFavorite
    case favorite(rate: Int)
}
