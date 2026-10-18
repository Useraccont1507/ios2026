//
//  LocationServiceStub.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
@testable import Zaryad

@MainActor
final class LocationServiceStub: PLocationService {
    // MARK: - Properties -
    let location: Coordinate?
    // MARK: - Init -
    init(location: Coordinate?) {
        self.location = location
    }
    // MARK: - PLocationService -
    func currentLocation() async -> Coordinate? {
        location
    }
}
