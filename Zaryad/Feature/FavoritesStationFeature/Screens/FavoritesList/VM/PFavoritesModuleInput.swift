//
//  PFavoritesModuleInput.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Вхід модуля для координатора.
protocol PFavoritesModuleInput: AnyObject {
    /// Очищає локальне обране (після виходу з акаунта).
    func clear()
}
