//
//  StationDetailsUIModel.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct StationDetailsUIModel: Equatable {
    let id: Int
    let name: String
    let address: String
    let coordinate: Coordinate
    let operatorName: String?
    let isOperational: Bool
    let statusText: String
    let usageText: String?
    let power: PowerTier
    let powerKW: Int?
    let pointsCount: Int?
    let connectors: [Connector]
    let description: String?
    let phone: String?
    let website: URL?
    let photos: [Photo]
    let lastVerifiedText: String?
}

extension StationDetailsUIModel {
    struct Connector: Identifiable, Equatable {
        let id: UUID
        let title: String
        let powerText: String
        let currentText: String?
        let quantity: Int?
        let isFast: Bool
    }

    struct Photo: Identifiable, Equatable {
        let id: UUID
        let url: URL
        let comment: String?
    }
}
