//
//  ToastPresenterSpy.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation
@testable import Zaryad

@MainActor
final class ToastPresenterSpy: PToastPresenter {
    // MARK: - Properties -
    private(set) var messages: [String] = []
    // MARK: - PToastPresenter -
    func show(_ message: String) {
        messages.append(message)
    }
}
