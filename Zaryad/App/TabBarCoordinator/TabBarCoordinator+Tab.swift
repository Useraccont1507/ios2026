//
//  Tab.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation
import UIKit

extension TabBarCoordinator {
    enum Tab: CaseIterable {
        case map
        case favorites
        case profile

        var tabBarItem: UITabBarItem {
            switch self {
            case .map:
                UITabBarItem(
                    title: "Карта",
                    image: UIImage(systemName: "map"),
                    selectedImage: UIImage(systemName: "map.fill")
                )
            case .favorites:
                UITabBarItem(
                    title: "Обране",
                    image: UIImage(systemName: "star"),
                    selectedImage: UIImage(systemName: "star.fill")
                )
            case .profile:
                UITabBarItem(
                    title: "Профіль",
                    image: UIImage(systemName: "person.crop.circle"),
                    selectedImage: UIImage(systemName: "person.crop.circle.fill")
                )
            }
        }
    }
}
