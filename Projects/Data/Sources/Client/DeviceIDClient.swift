//
//  DeviceIDClient.swift
//  Data
//
//  Created by 진준호 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Core
import Dependencies
import DependenciesMacros
import Foundation
import os

@DependencyClient
struct DeviceIDClient: Sendable {
    var getDeviceID: @Sendable () -> String
}

// MARK: - DependencyKey

extension DeviceIDClient: DependencyKey {
    private static let keychainKey = "com.peaktime.device-id"
    private static let cachedID = OSAllocatedUnfairLock<String?>(initialState: nil)

    static let liveValue = DeviceIDClient(
        getDeviceID: {
            cachedID.withLock { cached in
                if let cached { return cached }

                if let data = KeychainHelper.load(forKey: keychainKey),
                   let id = String(data: data, encoding: .utf8) {
                    cached = id
                    return id
                }

                let newID = UUID().uuidString
                if let data = newID.data(using: .utf8) {
                    _ = KeychainHelper.save(data: data, forKey: keychainKey)
                }

                cached = newID
                return newID
            }
        }
    )
}

extension DependencyValues {
    var deviceIDClient: DeviceIDClient {
        get { self[DeviceIDClient.self] }
        set { self[DeviceIDClient.self] = newValue }
    }
}
