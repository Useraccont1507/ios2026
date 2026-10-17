//
//  StationsRepository.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

final class StationsRepository: PStationsRepository {
    private let requestManager: PRequestManager
    private let mapper: StationMapper

    init(requestManager: PRequestManager, mapper: StationMapper = StationMapper()) {
        self.requestManager = requestManager
        self.mapper = mapper
    }

    func stations(near: Coordinate, radius: Double) async throws -> [ChargingStation] {
        let dtos = try await requestManager
            .sendData(OCMEndpoint.poi(near: near, radius: radius))
            .decode([OCMStationDTO].self)
        return mapper.map(dtos)
    }
}
