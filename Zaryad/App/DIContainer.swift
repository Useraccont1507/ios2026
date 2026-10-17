//
//  DIContainer.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Composition root: створює конкретні реалізації й роздає їх фічам як протоколи.
/// Репозиторії спільні, щоб зміни з одного табу (додати в обране з карти) бачив інший.
final class DIContainer {
    // TODO: - real repositories (лаб 4)
    let favoritesRepository: PFavoritesRepository = MockFavoritesRepository()
    let stationsRepository: PStationsRepository = MockStationsRepository()
}
