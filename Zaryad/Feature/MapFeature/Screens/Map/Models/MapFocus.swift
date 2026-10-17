//
//  MapFocus.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Запит на центрування камери. Свій `id` — щоб повторний запит на ту саму точку теж спрацював.
struct MapFocus: Equatable {
    let id = UUID()
    let coordinate: Coordinate
    /// Радіус видимої області в км.
    let radius: Double
}
