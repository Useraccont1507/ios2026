//
//  PStationsRepository.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PStationsRepository {
    /// - Parameters:
    ///   - near: центр пошуку
    ///   - radius: радіус пошуку в кілометрах
    func stations(near: Coordinate, radius: Double) async throws -> [ChargingStation]
}
