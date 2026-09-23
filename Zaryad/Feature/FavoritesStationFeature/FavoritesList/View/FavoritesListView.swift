//
//  FavoritesListView.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import SwiftUI

struct FavoritesListView<VM: PFavoriteListVM>: View {
    @ObservedObject var vm: VM
    // TEMP DEMO — прибрати, коли додавання переїде на MapView
    @State private var showAddDemoAlert = false

    var body: some View {
        NavigationStack {
            listContainer
                .navigationTitle("Обране")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { addDemoToolbarItem }   // TEMP DEMO
                .alert("Демонстраційне додавання", isPresented: $showAddDemoAlert) {
                    Button("Скасувати", role: .cancel) {}
                    Button("Додати") { vm.addDemoStation() }
                } message: {
                    Text("Це тимчасова дія для демонстрації сценарію. Згодом станції додаватимуться з карти (MapView). Додати демо-станцію в обране?")
                }
        }
    }

    private var listContainer: some View {
        List {
            if case let .list(stations) = vm.state {
                ForEach(stations) { item in
                    row(item)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await vm.refreshStations() }
        .overlay { stateOverlay }
        .animation(.default, value: stateKey)
    }

    @ViewBuilder
    private var stateOverlay: some View {
        switch vm.state {
        case .loading:
            ProgressView()
                .controlSize(.large)
        case .empty:
            ContentUnavailableView(
                "Немає обраного",
                systemImage: "star",
                description: Text("Додавайте станції в обране, щоб швидко повертатись до них.")
            )
        case .error:
            ContentUnavailableView {
                Label("Не вдалося завантажити", systemImage: "exclamationmark.triangle")
            } description: {
                Text("Перевірте з'єднання та спробуйте ще раз.")
            } actions: {
                Button("Повторити") {
                    Task { await vm.refreshStations() }
                }
                .buttonStyle(.borderedProminent)
            }
        case .list:
            EmptyView()
        }
    }

    private func row(_ item: FavoriteStationUIModel) -> some View {
        FavoriteStationCell(item: item) {
            vm.remove(station: item)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !item.needToDelete else { return }
            vm.didTap(station: item)
        }
        .opacity(item.needToDelete ? 0.5 : 1)
    }

    private var stateKey: Int {
        switch vm.state {
        case .loading: 0
        case .empty:   1
        case .error:   2
        case .list:    3
        }
    }

    // TEMP DEMO — кнопка-заглушка додавання (справжнє додавання буде з MapView)
    private var addDemoToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showAddDemoAlert = true
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Додати демо-станцію")
        }
    }
}

private struct FavoriteStationCell: View {
    let item: FavoriteStationUIModel
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            powerBadge

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(item.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    stars
                    if !item.connectorsText.isEmpty {
                        Text(item.connectorsText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 8)

            trailing
        }
        .padding(.vertical, 4)
        .animation(.default, value: item.needToDelete)
    }
    @ViewBuilder
    private var trailing: some View {
        if item.needToDelete {
            ProgressView().tint(.secondary)
        } else {
            HStack(spacing: 14) {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.borderless)
                .tint(.red)
                .accessibilityLabel("Видалити з обраного")

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }
    private var powerBadge: some View {
        VStack(spacing: 0) {
            Text(item.powerKW.map(String.init) ?? "—")
                .font(.system(size: 15, weight: .bold))
            Text("кВт")
                .font(.system(size: 9, weight: .semibold))
                .opacity(0.9)
        }
        .foregroundStyle(badgeTextColor)
        .frame(width: 46, height: 46)
        .background(Color(uiColor: item.power.color), in: Circle())
        .accessibilityElement()
        .accessibilityLabel("\(item.powerKW.map { "\($0) кіловат" } ?? "потужність невідома"), \(item.power.title)")
    }
    private var badgeTextColor: Color {
        item.power == .fast ? .black.opacity(0.85) : .white
    }
    private var stars: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= item.rate ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundStyle(.orange)
            }
        }
        .accessibilityLabel("Оцінка \(item.rate) з 5")
    }
}
