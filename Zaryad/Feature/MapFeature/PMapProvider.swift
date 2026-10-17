//
//  PMapProvider.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Той, хто вміє показати станцію на карті застосунку.
/// Реалізують `MapCoordinator` (всередині табу карти) і `TabBarCoordinator` (з інших табів).
protocol PMapProvider: AnyObject {
    func showStation(id: Int, at coordinate: Coordinate)
}
