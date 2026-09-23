//
//  PFavoriteListVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import Foundation

protocol PFavoriteListVM: ObservableObject {
    var state: FavoriteListViewState { get set }
    
    @Sendable func refreshStations() async
    func remove(station: FavoriteStationUIModel)
}
