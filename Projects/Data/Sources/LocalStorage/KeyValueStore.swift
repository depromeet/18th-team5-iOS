//
//  KeyValueStore.swift
//  Data
//
//  Created by choijunios on 5/20/26.
//  Copyright © 2026 Orange. All rights reserved.
//

actor KeyValueStore<Key: Hashable, Value> {
    private var store: [Key: Value] = [:]

    func set(_ value: Value, forKey key: Key) async {
        store[key] = value
    }

    func get(forKey key: Key) async -> Value? {
        store[key]
    }
}
