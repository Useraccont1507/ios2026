//
//  PMapProvider.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PMapProvider: AnyObject {
    func showStation(id: Int, at coordinate: Coordinate)
}
