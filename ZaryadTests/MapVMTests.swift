//
//  MapVMTests.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
import Testing
@testable import Zaryad

@MainActor
@Suite("MapVM")
struct MapVMTests {
    // MARK: - start -
    @Test("Є локація користувача → пошук і фокус карти навколо неї (FR-14)")
    func init_locationAvailable_searchesAroundUser() async {
        let repo = StationsRepositorySpy()
        let vm = makeMapVM(repo: repo, location: lviv)
        await settle()
        #expect(repo.requests.last?.center == lviv)
        #expect(vm.focus.coordinate == lviv)
    }
    @Test("Немає доступу до локації → пошук навколо Києва")
    func init_locationDenied_fallsBackToKyiv() async {
        let repo = StationsRepositorySpy()
        let vm = makeMapVM(repo: repo, location: nil)
        await settle()
        #expect(repo.requests.last?.center == .kyiv)
        #expect(vm.focus.coordinate == .kyiv)
    }
    // MARK: - search -
    @Test("Знайдені станції → стан loaded, список від найближчої (FR-1)")
    func search_stationsFound_loadedAndSortedByDistance() async {
        let repo = StationsRepositorySpy()
        repo.result = .success([
            makeStation(id: 1, latitude: 50.50, longitude: 30.52),
            makeStation(id: 2, latitude: 50.451, longitude: 30.5234)
        ])
        let vm = makeMapVM(repo: repo)
        await settle()
        #expect(vm.state == .loaded)
        #expect(vm.stations.map(\.id) == [2, 1])
        #expect(vm.stations[0].distanceKm < vm.stations[1].distanceKm)
    }
    @Test("Порожня відповідь → стан empty (NFR-4)")
    func search_noStations_isEmpty() async {
        let vm = makeMapVM()
        await settle()
        #expect(vm.state == .empty)
        #expect(vm.stations.isEmpty)
    }
    @Test("Помилка репозиторію → стан error (NFR-3)")
    func search_repositoryFails_isError() async {
        let repo = StationsRepositorySpy()
        repo.result = .failure(StubError())
        let vm = makeMapVM(repo: repo)
        await settle()
        #expect(vm.state == .error)
    }
    @Test("Повторити після помилки → той самий запит, дані завантажені (NFR-3)")
    func retry_afterError_repeatsLastQuery() async {
        let repo = StationsRepositorySpy()
        repo.result = .failure(StubError())
        let vm = makeMapVM(repo: repo, location: lviv)
        await settle()
        repo.result = .success([makeStation(id: 7)])
        vm.retry()
        await settle()
        #expect(vm.state == .loaded)
        #expect(repo.requests.suffix(2).map(\.center) == [lviv, lviv])
    }
    @Test("Пошук у видимій зоні карти → запит з центром і радіусом зони (FR-12)")
    func search_visibleArea_requestsThatArea() async {
        let repo = StationsRepositorySpy()
        let vm = makeMapVM(repo: repo)
        await settle()
        vm.search(near: lviv, radius: 3)
        await settle()
        #expect(repo.requests.last?.center == lviv)
        #expect(repo.requests.last?.radius == 3)
    }
    // MARK: - openDetails -
    @Test("Тап по станції у списку → відкриваються деталі саме цієї станції (FR-3)")
    func openDetails_knownId_passesDomainStation() async {
        let repo = StationsRepositorySpy()
        repo.result = .success([makeStation(id: 1), makeStation(id: 2)])
        let vm = makeMapVM(repo: repo)
        await settle()
        var opened: [Int] = []
        vm.onOpenDetails = { opened.append($0.id) }
        vm.openDetails(id: 2)
        vm.openDetails(id: 999)
        #expect(opened == [2])
    }
}
