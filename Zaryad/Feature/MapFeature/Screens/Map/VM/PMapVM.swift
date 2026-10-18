//
//  PMapVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PMapVM: ObservableObject {
    var state: MapViewState { get }
    var stations: [MapStationUIModel] { get }
    var focus: MapFocus { get }
    var selectedStation: MapStationUIModel? { get }

    func search(near: Coordinate, radius: Double)
    func selectStation(id: Int)
    func deselectStation()
    func openDetails()
    func openDetails(id: Int)
    func retry()
}

protocol PMapModuleInput: AnyObject {
    func showStation(id: Int, at coordinate: Coordinate)
}
