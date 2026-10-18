//
//  StationsRepositorySpy.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
@testable import Zaryad

@MainActor
final class StationsRepositorySpy: PStationsRepository {
    // MARK: - Properties -
    var result: Result<[ChargingStation], Error> = .success([])
    private(set) var requests: [(center: Coordinate, radius: Double)] = []
    // MARK: - PStationsRepository -
    func stations(near: Coordinate, radius: Double) async throws -> [ChargingStation] {
        requests.append((near, radius))
        return try result.get()
    }
}

struct StubError: Error {}
