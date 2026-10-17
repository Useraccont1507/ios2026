//
//  PLocationService.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PLocationService: AnyObject {
    func currentLocation() async -> Coordinate?
}
