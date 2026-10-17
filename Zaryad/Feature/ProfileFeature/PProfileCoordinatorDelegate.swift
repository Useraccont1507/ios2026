//
//  PProfileCoordinatorDelegate.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PProfileCoordinatorDelegate: AnyObject {
    func profileCoordinatorDidSignOut(_ coordinator: ProfileCoordinator)
}
