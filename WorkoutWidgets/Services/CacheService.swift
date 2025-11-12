//
//  CacheService.swift
//  WorkoutWidgets
//
//  Created by Assistant on 2025-11-12.
//

import Foundation

final class CacheService<Value: Codable> {
    private let store: UserDefaults
    private let key: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(suiteName: String, key: String, encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        guard let ud = UserDefaults(suiteName: suiteName) else {
            fatalError("Invalid App Group suite name: \(suiteName)")
        }
        self.store = ud
        self.key = key
        self.encoder = encoder
        self.decoder = decoder
    }

    func load() -> Value? {
        guard let data = store.data(forKey: key) else { return nil }
        do {
            return try decoder.decode(Value.self, from: data)
        } catch {
            // Clear corrupted data
            clear()
            return nil
        }
    }

    func save(_ value: Value) {
        do {
            let data = try encoder.encode(value)
            store.set(data, forKey: key)
        } catch {
            // If encoding fails, ensure there's no stale/partial data
            clear()
        }
    }

    func clear() {
        store.removeObject(forKey: key)
    }
}
