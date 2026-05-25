//
//  SingleValueStore.swift
//  Data
//
//  Created by choijunios on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

actor SingleValueStore<T> {
    private var data: T?

    init() {}

    func set(value: T) {
        data = value
    }

    func value() -> T? {
        data
    }
}
