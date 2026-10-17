//
//  PMapVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PMapVM: ObservableObject {
    var state: MapViewState { get }
    /// Точка, на яку карта має відцентруватись (стартова або прийшла з іншого табу).
    var focus: Coordinate { get }
    var selectedStation: MapStationUIModel? { get }

    /// Викликати, коли користувач зупинив рух карти. `radius` — у кілометрах.
    func search(near: Coordinate, radius: Double)
    func selectStation(id: Int)
    func deselectStation()
    func retry()
}

/// Вхід модуля для координатора (крос-табова взаємодія).
protocol PMapModuleInput: AnyObject {
    func showStation(id: Int, at coordinate: Coordinate)
}
