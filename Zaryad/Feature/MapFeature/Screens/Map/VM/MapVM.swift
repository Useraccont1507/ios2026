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
    @Published private(set) var focus: Coordinate
    @Published private(set) var selectedStation: MapStationUIModel?

    var onStationSelected: ((ChargingStation) -> Void)?

    private let repo: PStationsRepository
    private var domainStationsById: [Int: ChargingStation]
    private var lastQuery: (center: Coordinate, radius: Double)
    private var pendingSelectionId: Int?
    private var searchTask: Task<Void, Never>?

    init(repo: PStationsRepository, center: Coordinate = .kyiv, radius: Double = MapVM.defaultRadius) {
        self.state = .loading
        self.focus = center
        self.repo = repo
        self.domainStationsById = [:]
        self.lastQuery = (center, radius)
        search(near: center, radius: radius)
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
                apply(result: result)
            } catch is CancellationError {
            } catch {
                state = .error
            }
        }
    }
    func selectStation(id: Int) {
        guard case let .loaded(stations) = state,
              let station = stations.first(where: { $0.id == id }) else { return }
        selectedStation = station
        if let domain = domainStationsById[id] {
            onStationSelected?(domain)
        }
    }
    func deselectStation() {
        selectedStation = nil
    }
    func retry() {
        search(near: lastQuery.center, radius: lastQuery.radius)
    }
    private func apply(result: [ChargingStation]) {
        let stations = MapStationUIMapper().map(result)
        state = stations.isEmpty ? .empty : .loaded(stations: stations)
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
        focus = coordinate
        pendingSelectionId = id
        search(near: coordinate, radius: lastQuery.radius)
    }
}
