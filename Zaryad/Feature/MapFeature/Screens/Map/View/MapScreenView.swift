//
//  MapScreenView.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import SwiftUI

struct MapScreenView<VM: PMapVM>: View {
    @ObservedObject var vm: VM

    var body: some View {
        mapContainer
            .overlay { stateOverlay }
            .navigationTitle("Карта")
            .navigationBarTitleDisplayMode(.inline)
    }

    // TODO: - MapKit
    // - камера: стартує з `vm.focus`, реагує на його зміну (`onChange(of: vm.focus)`)
    // - піни: `vm.state` → `.loaded(stations)`, колір — `station.power.color`
    // - тап по піну → `vm.selectStation(id:)`, вибрана — `vm.selectedStation`
    // - кінець руху камери → `vm.search(near:radius:)` (radius у км)
    private var mapContainer: some View {
        Color(uiColor: .secondarySystemBackground)
            .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private var stateOverlay: some View {
        switch vm.state {
        case .loading:
            ProgressView()
                .controlSize(.large)
        case .empty:
            ContentUnavailableView(
                "Нічого не знайдено",
                systemImage: "bolt.slash",
                description: Text("У цьому районі немає зарядних станцій. Спробуйте змістити карту.")
            )
        case .error:
            ContentUnavailableView {
                Label("Не вдалося завантажити", systemImage: "exclamationmark.triangle")
            } description: {
                Text("Перевірте з'єднання та спробуйте ще раз.")
            } actions: {
                Button("Повторити") { vm.retry() }
                    .buttonStyle(.borderedProminent)
            }
        case .loaded:
            EmptyView()
        }
    }
}
