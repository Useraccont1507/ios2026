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
        List {
            switch vm.state {
            case .empty: emptyState
            case .loading: loading
            case .error: errorState
            case .list(let stations):
                list(with: stations)
            }
        }
        .refreshable(action: vm.refreshStations)
    }
    private var errorState: some View {
        // TODO: - Error state
        EmptyView()
    }
    private var loading: some View {
        // TODO: - loading state
        EmptyView()
    }
    private var emptyState: some View {
        // TODO: - empty state
        EmptyView()
    }
    private func list(with items: [FavoriteStationUIModel]) -> some View {
        // TODO: - list state
        EmptyView()
    }
}
