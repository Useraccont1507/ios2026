//
//  StationDetailsView.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import SwiftUI
import MapKit

struct StationDetailsView<VM: PStationDetailsVM>: View {
    @ObservedObject var vm: VM
    @State private var isRatingPopupShown = false

    private var details: StationDetailsUIModel { vm.details }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                titleBlock
                actions
                specs
                connectors
                if let description = details.description {
                    section("Опис") {
                        Text(description)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                contacts
            }
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(details.name)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isRatingPopupShown) {
            RatingPopup(
                onSubmit: { vm.addToFavorites(rate: $0) },
                onClose: { vm.isRatingPopupPresented = false }
            )
            .presentationBackground(.clear)
        }
        .onChange(of: vm.isRatingPopupPresented) { _, isPresented in
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { isRatingPopupShown = isPresented }
        }
    }

    // MARK: - Header
    @ViewBuilder
    private var header: some View {
        if details.photos.isEmpty {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: details.coordinate.clCoordinate,
                latitudinalMeters: 600,
                longitudinalMeters: 600
            )), interactionModes: []) {
                Marker(details.name, systemImage: "bolt.fill", coordinate: details.coordinate.clCoordinate)
                    .tint(Color(uiColor: details.power.color))
            }
            .frame(height: 200)
            .overlay(alignment: .bottomTrailing) { showOnMapButton }
        } else {
            TabView {
                ForEach(details.photos) { photo in
                    AsyncImage(url: photo.url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        default:
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipped()
                }
            }
            .tabViewStyle(.page)
            .frame(height: 240)
            .overlay(alignment: .bottomTrailing) { showOnMapButton }
        }
    }

    private var showOnMapButton: some View {
        Button {
            vm.showOnMap()
        } label: {
            Label("На карті", systemImage: "map.fill")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.regularMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
        .padding(12)
    }

    // MARK: - Title
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Text(details.name)
                    .font(.title2.bold())
                Spacer(minLength: 8)
                statusPill
            }
            if let operatorName = details.operatorName {
                Text(operatorName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            Label(details.address, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private var statusPill: some View {
        Text(details.statusText)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(details.isOperational ? .green : .secondary)
            .background(
                (details.isOperational ? Color.green : Color.secondary).opacity(0.15),
                in: Capsule()
            )
    }

    // MARK: - Actions
    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                vm.openRoute()
            } label: {
                Label("Маршрут", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                vm.favoriteButtonTapped()
            } label: {
                favoriteLabel
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.orange)
            .disabled(vm.favoriteState == .loading || vm.isFavoriteProcessing)
        }
        .controlSize(.large)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var favoriteLabel: some View {
        if vm.isFavoriteProcessing || vm.favoriteState == .loading {
            ProgressView()
        } else if case let .favorite(rate) = vm.favoriteState {
            Label("В обраному · \(rate)", systemImage: "star.fill")
        } else {
            Label("В обране", systemImage: "star")
        }
    }

    // MARK: - Specs
    private var specs: some View {
        section("Характеристики") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                specTile("Макс. потужність", value: details.powerKW.map { "\($0) кВт" } ?? "—",
                         icon: "bolt.fill", tint: Color(uiColor: details.power.color))
                specTile("Тип", value: details.power.title, icon: "gauge.with.dots.needle.67percent", tint: .blue)
                specTile("Точок зарядки", value: details.pointsCount.map(String.init) ?? "—",
                         icon: "ev.charger", tint: .teal)
                specTile("Доступ", value: details.usageText ?? "—", icon: "person.2.fill", tint: .purple)
            }
            if let lastVerified = details.lastVerifiedText {
                Text("Дані перевірено \(lastVerified)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func specTile(_ title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(value)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Connectors
    @ViewBuilder
    private var connectors: some View {
        if !details.connectors.isEmpty {
            section("Роз'єми") {
                VStack(spacing: 0) {
                    ForEach(details.connectors) { connector in
                        HStack(spacing: 12) {
                            Image(systemName: "powerplug.fill")
                                .foregroundStyle(connector.isFast ? .orange : .secondary)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(connector.title)
                                    .font(.subheadline.weight(.semibold))
                                if let current = connector.currentText, !current.isEmpty {
                                    Text(current)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(connector.powerText)
                                    .font(.subheadline.weight(.semibold))
                                if let quantity = connector.quantity {
                                    Text("× \(quantity)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(12)
                        if connector != details.connectors.last {
                            Divider().padding(.leading, 48)
                        }
                    }
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Contacts
    @ViewBuilder
    private var contacts: some View {
        if details.phone != nil || details.website != nil {
            section("Контакти") {
                VStack(alignment: .leading, spacing: 12) {
                    if let phone = details.phone,
                       let url = URL(string: "tel:\(phone.filter { $0.isNumber || $0 == "+" })") {
                        Link(destination: url) {
                            Label(phone, systemImage: "phone.fill")
                        }
                    }
                    if let website = details.website {
                        Link(destination: website) {
                            Label(website.host() ?? website.absoluteString, systemImage: "globe")
                        }
                    }
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Helpers
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding(.horizontal, 16)
    }
}
