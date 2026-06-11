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
    var deleteDeviceID: @Sendable () -> Void
}

// MARK: - DependencyKey

extension DeviceIDClient: DependencyKey {
    private static let cachedID = OSAllocatedUnfairLock<String?>(initialState: nil)

    static let liveValue = {
        @Dependency(\.logger) var logger
        return DeviceIDClient(
            getDeviceID: {
                cachedID.withLock { cached in
                    if let cached { return cached }

                    if let data = KeychainHelper.load(forKey: .deviceID),
                       let id = String(data: data, encoding: .utf8) {
                        cached = id
                        return id
                    }

                    return nil
                }
            },
            createDeviceID: {
                let newID = UUID().uuidString
                cachedID.withLock { cached in
                    if let data = newID.data(using: .utf8) {
                        if !KeychainHelper.save(data: data, forKey: .deviceID) {
                            logger.error(message: "DeviceID Keychain 저장 실패")
                        }
                    }
                    cached = newID
                }
                return newID
            },
            deleteDeviceID: {
                cachedID.withLock { cached in
                    if !KeychainHelper.delete(forKey: .deviceID) {
                        logger.error(message: "DeviceID Keychain 삭제 실패")
                    }
                    cached = nil
                }
            }
        )
    }()
}

extension DependencyValues {
    var deviceIDClient: DeviceIDClient {
        get { self[DeviceIDClient.self] }
        set { self[DeviceIDClient.self] = newValue }
    }
}
