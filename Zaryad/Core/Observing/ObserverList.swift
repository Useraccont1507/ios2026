//
//  ObserverList.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

final class ObserverList<Value> {
    private struct Entry {
        weak var owner: AnyObject?
        let handler: @MainActor (Value) -> Void
    }

    private var entries: [Entry] = []

    func add(owner: AnyObject, _ handler: @escaping @MainActor (Value) -> Void) {
        removeReleased()
        entries.append(Entry(owner: owner, handler: handler))
    }

    func notify(_ value: Value) {
        removeReleased()
        let handlers = entries.map(\.handler)
        Task { @MainActor in
            handlers.forEach { $0(value) }
        }
    }

    private func removeReleased() {
        entries.removeAll { $0.owner == nil }
    }
}
