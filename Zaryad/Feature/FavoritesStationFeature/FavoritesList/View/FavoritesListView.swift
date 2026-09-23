//
//  FavoritesListView.swift
//  Zaryad
//
//  Created by Illia Verezei on 23.09.2026.
//

import SwiftUI

struct FavoritesListView<VM: PFavoriteListVM>: View {
    @ObservedObject var vm: VM
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Обране")
                .navigationBarTitleDisplayMode(.large)
        }
    }
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .loading:            loadingState
        case .empty:              emptyState
        case .error:              errorState
        case .list(let stations): list(with: stations)
        }
    }
    private var loadingState: some View {
        ProgressView("Завантаження…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    private var emptyState: some View {
        ContentUnavailableView(
            "Немає обраного",
            systemImage: "star",
            description: Text("Додавайте станції в обране, щоб швидко повертатись до них.")
        )
    }
    private var errorState: some View {
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
    }
    private func list(with items: [FavoriteStationUIModel]) -> some View {
        List(items) { item in
            FavoriteStationCell(item: item)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard !item.needToDelete else { return }
                    vm.didTap(station: item)
                }
                .opacity(item.needToDelete ? 0.5 : 1)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if !item.needToDelete {
                        Button(role: .destructive) {
                            vm.remove(station: item)
                        } label: {
                            Label("Видалити", systemImage: "trash")
                        }
                    }
                }
        }
        .listStyle(.insetGrouped)
        .refreshable { await vm.refreshStations() }
    }
}

private struct FavoriteStationCell: View {
    let item: FavoriteStationUIModel

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

            if item.needToDelete {
                ProgressView().tint(.secondary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .animation(.default, value: item.needToDelete)
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
