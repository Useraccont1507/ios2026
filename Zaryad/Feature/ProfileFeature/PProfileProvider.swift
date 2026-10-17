//
//  PProfileProvider.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Той, хто вміє відкрити профіль (вхід) з будь-якого місця застосунку.
/// Реалізують `ProfileCoordinator` (всередині табу профілю) і `TabBarCoordinator` (з інших табів).
protocol PProfileProvider: AnyObject {
    func showProfile()
}
