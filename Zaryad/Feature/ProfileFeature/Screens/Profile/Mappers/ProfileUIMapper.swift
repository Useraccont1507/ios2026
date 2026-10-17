//
//  ProfileUIMapper.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct ProfileUIMapper {
    func map(_ account: Account, favoritesCount: Int?) -> ProfileUIModel {
        let name = account.displayName ?? String(account.email.prefix { $0 != "@" })

        let initials = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()

        return ProfileUIModel(
            initials: initials.isEmpty ? "?" : initials,
            name: name,
            email: account.email,
            memberSinceText: account.createdAt.formatted(
                .dateTime.day().month(.wide).year().locale(Locale(identifier: "uk_UA"))
            ),
            favoritesText: favoritesCount.map { "\($0) \(Self.stationsWord(for: $0))" } ?? "—"
        )
    }

    private static func stationsWord(for count: Int) -> String {
        let mod10 = count % 10, mod100 = count % 100
        if mod10 == 1 && mod100 != 11 { return "станція" }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "станції" }
        return "станцій"
    }
}
