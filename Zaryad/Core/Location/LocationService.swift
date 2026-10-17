//
//  LocationService.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import CoreLocation

final class LocationService: NSObject, PLocationService {
    private let manager = CLLocationManager()
    private let timeout: Duration
    private var authorizationContinuations: [CheckedContinuation<Void, Never>] = []
    private var locationContinuations: [CheckedContinuation<Coordinate?, Never>] = []

    init(timeout: Duration = .seconds(5)) {
        self.timeout = timeout
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func currentLocation() async -> Coordinate? {
        await requestAuthorizationIfNeeded()
        guard isAuthorized else { return nil }
        if let location = manager.location, location.timestamp.timeIntervalSinceNow > -60 {
            return location.coordinate.coordinate
        }
        return await requestLocation()
    }

    private var isAuthorized: Bool {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways: true
        default: false
        }
    }

    private func requestAuthorizationIfNeeded() async {
        guard manager.authorizationStatus == .notDetermined else { return }
        await withCheckedContinuation { continuation in
            authorizationContinuations.append(continuation)
            manager.requestWhenInUseAuthorization()
        }
    }

    private func requestLocation() async -> Coordinate? {
        let timeoutTask = Task { [weak self, timeout] in
            try? await Task.sleep(for: timeout)
            guard !Task.isCancelled else { return }
            self?.finishLocationRequest(with: nil)
        }
        defer { timeoutTask.cancel() }
        return await withCheckedContinuation { continuation in
            locationContinuations.append(continuation)
            if locationContinuations.count == 1 {
                manager.requestLocation()
            }
        }
    }

    private func finishLocationRequest(with coordinate: Coordinate?) {
        let continuations = locationContinuations
        locationContinuations.removeAll()
        continuations.forEach { $0.resume(returning: coordinate) }
    }
}

extension LocationService: @MainActor CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else { return }
        let continuations = authorizationContinuations
        authorizationContinuations.removeAll()
        continuations.forEach { $0.resume() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        finishLocationRequest(with: locations.last?.coordinate.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finishLocationRequest(with: nil)
    }
}
