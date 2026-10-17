//
//  PStationDetailsVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PStationDetailsVM: ObservableObject {
    var details: StationDetailsUIModel { get }
    var favoriteState: StationFavoriteState { get }
    var isFavoriteProcessing: Bool { get }
    var isRatingPopupPresented: Bool { get set }

    func favoriteButtonTapped()
    func addToFavorites(rate: Int)
    func openRoute()
    func showOnMap()
}
