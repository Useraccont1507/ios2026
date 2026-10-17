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

    /// Не в обраному — показує попап з оцінкою, в обраному — видаляє.
    func favoriteButtonTapped()
    func addToFavorites(rate: Int)
    /// Відкриває Apple Maps з маршрутом до станції.
    func openRoute()
    func showOnMap()
}
