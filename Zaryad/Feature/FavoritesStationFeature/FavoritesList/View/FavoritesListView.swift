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
        content
            .navigationTitle("Обране")
            .navigationBarTitleDisplayMode(.large)
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

    // MARK: - States

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
            FavoriteStationCell(item: item) {
                vm.remove(station: item)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await vm.refreshStations() }
    }
}

// MARK: - Cell

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
        .opacity(item.needToDelete ? 0.5 : 1)
        .animation(.default, value: item.needToDelete)
    }

    // MARK: Subviews

    private var powerBadge: some View {
        Image(systemName: "bolt.fill")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(Color(uiColor: item.power.color), in: Circle())
            .accessibilityLabel("Потужність: \(item.power.title)")
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

    @ViewBuilder
    private var trailing: some View {
        if item.needToDelete {
            ProgressView()
                .tint(.secondary)
                .frame(width: 28, height: 28)
        } else {
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .semibold))
            }
            .buttonStyle(.borderless)
            .tint(.red)
            .frame(width: 28, height: 28)
            .accessibilityLabel("Видалити з обраного")
        }
    }
}
