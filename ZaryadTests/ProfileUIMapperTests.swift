//
//  ProfileUIMapperTests.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
import Testing
@testable import Zaryad

@MainActor
@Suite("ProfileUIMapper")
struct ProfileUIMapperTests {
    // MARK: - name / initials -
    @Test("Ім'я з акаунта → ініціали з перших двох слів")
    func map_displayName_initialsFromTwoWords() {
        let model = ProfileUIMapper().map(makeAccount(displayName: "ілля олексійович верезей"), favoritesCount: nil)
        #expect(model.initials == "ІО")
    }
    @Test("Без імені → ім'я з частини email до @")
    func map_noDisplayName_usesEmailPrefix() {
        let model = ProfileUIMapper().map(makeAccount(email: "volt@zaryad.app", displayName: nil), favoritesCount: nil)
        #expect(model.name == "volt")
        #expect(model.initials == "V")
    }
    // MARK: - favoritesText -
    @Test("Відмінювання «станція» за числом", arguments: [
        (1, "1 станція"), (2, "2 станції"), (5, "5 станцій"), (11, "11 станцій"),
        (21, "21 станція"), (22, "22 станції"), (14, "14 станцій"), (0, "0 станцій")
    ])
    func map_favoritesCount_pluralized(count: Int, text: String) {
        #expect(ProfileUIMapper().map(makeAccount(), favoritesCount: count).favoritesText == text)
    }
    @Test("Кількість ще не завантажена → тире")
    func map_unknownCount_dash() {
        #expect(ProfileUIMapper().map(makeAccount(), favoritesCount: nil).favoritesText == "—")
    }
}
