//
//  MapVM.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Combine
import Foundation

final class MapVM: PMapVM {
    static let defaultRadius: Double = 10

    @Published private(set) var state: MapViewState
    @Published private(set) var stations: [MapStationUIModel]
    @Published private(set) var focus: MapFocus
    @Published private(set) var selectedStation: MapStationUIModel?

    var onOpenDetails: ((ChargingStation) -> Void)?

    private let repo: PStationsRepository
    private let locationService: PLocationService
    private var domainStationsById: [Int: ChargingStation]
    private var lastQuery: (center: Coordinate, radius: Double)
    private var pendingSelectionId: Int?
    private var searchTask: Task<Void, Never>?

    init(
        repo: PStationsRepository,
        locationService: PLocationService,
        fallbackCenter: Coordinate = .kyiv,
        radius: Double = MapVM.defaultRadius
    ) {
        self.state = .loading
        self.stations = []
        self.focus = MapFocus(coordinate: fallbackCenter, radius: radius)
        self.repo = repo
        self.locationService = locationService
        self.domainStationsById = [:]
        self.lastQuery = (fallbackCenter, radius)
        startFromUserLocation(fallbackCenter: fallbackCenter, radius: radius)
    }
    func search(near: Coordinate, radius: Double) {
        searchTask?.cancel()
        lastQuery = (near, radius)
        state = .loading
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let result = try await repo.stations(near: near, radius: radius)
                guard !Task.isCancelled else { return }
                apply(result: result, center: near)
            } catch {
                guard !Task.isCancelled else { return }
                state = .error
            }
        }
    }
    func selectStation(id: Int) {
        guard let station = stations.first(where: { $0.id == id }) else { return }
        selectedStation = station
    }
    func deselectStation() {
        selectedStation = nil
    }
    func openDetails() {
        guard let id = selectedStation?.id else { return }
        openDetails(id: id)
    }
    func openDetails(id: Int) {
        guard let domain = domainStationsById[id] else { return }
        onOpenDetails?(domain)
    }
    func retry() {
        search(near: lastQuery.center, radius: lastQuery.radius)
    }
    private func startFromUserLocation(fallbackCenter: Coordinate, radius: Double) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let center = await locationService.currentLocation() ?? fallbackCenter
            guard pendingSelectionId == nil else { return }
            focus = MapFocus(coordinate: center, radius: radius)
            search(near: center, radius: radius)
        }
    }
    private func apply(result: [ChargingStation], center: Coordinate) {
        stations = MapStationUIMapper().map(result, from: center)
        state = stations.isEmpty ? .empty : .loaded
        domainStationsById = [:]
        result.forEach {
            domainStationsById[$0.id] = $0
        }
        if let id = pendingSelectionId {
            pendingSelectionId = nil
            selectStation(id: id)
        } else if let selected = selectedStation, domainStationsById[selected.id] == nil {
            selectedStation = nil
        }
    }
}

// MARK: - PMapModuleInput
extension MapVM: PMapModuleInput {
    func showStation(id: Int, at coordinate: Coordinate) {
        focus = MapFocus(coordinate: coordinate, radius: 1)
        pendingSelectionId = id
        search(near: coordinate, radius: lastQuery.radius)
    }
}
