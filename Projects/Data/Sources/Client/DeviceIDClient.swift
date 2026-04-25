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
    var getDeviceID: @Sendable () -> String?
    var createDeviceID: @Sendable () -> String = { UUID().uuidString }
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

                return nil
            }
        },
        createDeviceID: {
            let newID = UUID().uuidString
            cachedID.withLock { $0 = newID }
            if let data = newID.data(using: .utf8) {
                _ = KeychainHelper.save(data: data, forKey: keychainKey)
            }
            return newID
        }
    )
}

extension DependencyValues {
    var deviceIDClient: DeviceIDClient {
        get { self[DeviceIDClient.self] }
        set { self[DeviceIDClient.self] = newValue }
    }
}
