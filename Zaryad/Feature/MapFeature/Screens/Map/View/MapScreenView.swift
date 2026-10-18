//
//  MapScreenView.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import SwiftUI
import MapKit

struct MapScreenView<VM: PMapVM>: View {
    @ObservedObject var vm: VM
    @State private var position: MapCameraPosition
    @State private var mode: Mode = .map

    init(vm: VM) {
        self.vm = vm
        _position = State(initialValue: .region(Self.region(for: vm.focus)))
    }

    var body: some View {
        content
            .overlay(alignment: .top) { statusBanner }
            .safeAreaInset(edge: .top) { modePicker }
            .navigationTitle("Карта")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: vm.focus) { _, focus in
                withAnimation {
                    position = .region(Self.region(for: focus))
                }
            }
            .onChange(of: vm.selectedStation?.id) { _, id in
                if id != nil { mode = .map }
            }
    }

    private var modePicker: some View {
        Picker("Режим", selection: $mode) {
            ForEach(Mode.allCases, id: \.self) { Text($0.title).tag($0) }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 260)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var content: some View {
        switch mode {
        case .map:
            map.safeAreaInset(edge: .bottom) { selectedCard }
        case .list:
            StationsList(stations: vm.stations) { vm.openDetails(id: $0) }
        }
    }

    private var map: some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(vm.stations) { station in
                Annotation(station.name, coordinate: station.coordinate.clCoordinate, anchor: .bottom) {
                    StationPin(station: station, isSelected: station.id == vm.selectedStation?.id)
                        .onTapGesture { vm.selectStation(id: station.id) }
                }
                .annotationTitles(.hidden)
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            vm.search(near: context.region.center.coordinate, radius: Self.radius(of: context.region))
        }
    }

    // MARK: - Status
    @ViewBuilder
    private var statusBanner: some View {
        switch vm.state {
        case .loading:
            banner {
                ProgressView()
                Text("Пошук станцій…")
            }
        case .empty:
            banner {
                Image(systemName: "bolt.slash")
                Text("Поруч немає станцій. Змістіть карту.")
            }
        case .error:
            banner {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                Text("Не вдалося завантажити")
                Button("Повторити") { vm.retry() }
                    .buttonStyle(.borderless)
                    .fontWeight(.semibold)
            }
        case .loaded:
            EmptyView()
        }
    }

    private func banner<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 8) { content() }
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.default, value: vm.state)
    }

    // MARK: - Selected station
    @ViewBuilder
    private var selectedCard: some View {
        if let station = vm.selectedStation {
            SelectedStationCard(
                station: station,
                onDetails: { vm.openDetails() },
                onClose: { vm.deselectStation() }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - Geometry helpers
private extension MapScreenView {
    static func region(for focus: MapFocus) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: focus.coordinate.clCoordinate,
            latitudinalMeters: focus.radius * 2000,
            longitudinalMeters: focus.radius * 2000
        )
    }
    static func radius(of region: MKCoordinateRegion) -> Double {
        let kmPerDegree = 111.0
        let latKm = region.span.latitudeDelta * kmPerDegree
        let lonKm = region.span.longitudeDelta * kmPerDegree * cos(region.center.latitude * .pi / 180)
        return min(max(min(latKm, lonKm) / 2, 1), 50)
    }
}

// MARK: - StationPin
private struct StationPin: View {
    let station: MapStationUIModel
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(station.powerKW.map(String.init) ?? "—")
                .font(.system(size: isSelected ? 15 : 12, weight: .bold))
                .foregroundStyle(station.power == .fast ? .black.opacity(0.85) : .white)
                .frame(width: isSelected ? 44 : 34, height: isSelected ? 44 : 34)
                .background(Color(uiColor: station.power.color), in: Circle())
                .overlay(Circle().stroke(.white, lineWidth: 2))
                .overlay(alignment: .topTrailing) {
                    if !station.isOperational {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(.white, .gray)
                            .offset(x: 4, y: -4)
                    }
                }
            Image(systemName: "triangle.fill")
                .font(.system(size: 9))
                .foregroundStyle(Color(uiColor: station.power.color))
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
        .opacity(station.isOperational ? 1 : 0.6)
        .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
        .animation(.spring(duration: 0.25), value: isSelected)
        .accessibilityElement()
        .accessibilityLabel("\(station.name), \(station.powerKW.map { "\($0) кіловат" } ?? "потужність невідома")")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - SelectedStationCard
private struct SelectedStationCard: View {
    let station: MapStationUIModel
    let onDetails: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            info
            Button(action: onDetails) {
                Text("Детальніше")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
    }

    private var info: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Text(station.powerKW.map(String.init) ?? "—")
                    .font(.system(size: 15, weight: .bold))
                Text("кВт")
                    .font(.system(size: 9, weight: .semibold))
                    .opacity(0.9)
            }
            .foregroundStyle(station.power == .fast ? .black.opacity(0.85) : .white)
            .frame(width: 46, height: 46)
            .background(Color(uiColor: station.power.color), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(station.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Label(
                        station.isOperational ? "Працює" : "Недоступна",
                        systemImage: station.isOperational ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .foregroundStyle(station.isOperational ? .green : .secondary)
                    if !station.connectorsText.isEmpty {
                        Text("· \(station.connectorsText)")
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .font(.caption)
                if let operatorName = station.operatorName {
                    Text(operatorName)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer(minLength: 0)

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary, .quaternary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Закрити")
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onDetails)
    }
}

// MARK: - Mode
private enum Mode: CaseIterable {
    case map, list

    var title: String {
        switch self {
        case .map: "Карта"
        case .list: "Список"
        }
    }
}

// MARK: - StationsList
private struct StationsList: View {
    let stations: [MapStationUIModel]
    let onSelect: (Int) -> Void

    var body: some View {
        List(stations) { station in
            Button { onSelect(station.id) } label: {
                StationRow(station: station)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }
}

private struct StationRow: View {
    let station: MapStationUIModel
    @ScaledMetric(relativeTo: .subheadline) private var badgeSize: CGFloat = 44

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                Text(station.powerKW.map(String.init) ?? "—")
                    .font(.subheadline.bold())
                Text("кВт")
                    .font(.caption2.weight(.semibold))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(4)
            .foregroundStyle(station.power == .fast ? .black.opacity(0.85) : .white)
            .frame(width: badgeSize, height: badgeSize)
            .background(Color(uiColor: station.power.color), in: Circle())
            .opacity(station.isOperational ? 1 : 0.5)

            VStack(alignment: .leading, spacing: 3) {
                Text(station.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(station.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if !station.connectorsText.isEmpty {
                    Text(station.connectorsText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Text(station.distanceKm.formatted(.number.precision(.fractionLength(1))) + " км")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}
