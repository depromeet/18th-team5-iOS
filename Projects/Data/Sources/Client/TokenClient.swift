//
//  TokenClient.swift
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
struct TokenClient: Sendable {
    var getAccessToken: @Sendable () -> String?
    var getRefreshToken: @Sendable () -> String?
    var saveTokens: @Sendable (_ accessToken: String, _ refreshToken: String) -> Void
    var clearTokens: @Sendable () -> Void
}

// MARK: - DependencyKey

extension TokenClient: DependencyKey {
    private static let accessTokenKey = "com.peaktime.access-token"
    private static let refreshTokenKey = "com.peaktime.refresh-token"
    private static let storage = OSAllocatedUnfairLock<(access: String?, refresh: String?)>(
        initialState: (nil, nil)
    )

    static let liveValue = TokenClient(
        getAccessToken: {
            storage.withLock { state in
                if let token = state.access { return token }

                if let data = KeychainHelper.load(forKey: accessTokenKey),
                   let token = String(data: data, encoding: .utf8) {
                    state.access = token
                    return token
                }

                return nil
            }
        },
        getRefreshToken: {
            storage.withLock { state in
                if let token = state.refresh { return token }

                if let data = KeychainHelper.load(forKey: refreshTokenKey),
                   let token = String(data: data, encoding: .utf8) {
                    state.refresh = token
                    return token
                }

                return nil
            }
        },
        saveTokens: { accessToken, refreshToken in
            storage.withLock { state in
                state = (accessToken, refreshToken)
            }

            if let data = accessToken.data(using: .utf8) {
                _ = KeychainHelper.save(data: data, forKey: accessTokenKey)
            }
            if let data = refreshToken.data(using: .utf8) {
                _ = KeychainHelper.save(data: data, forKey: refreshTokenKey)
            }
        },
        clearTokens: {
            storage.withLock { state in
                state = (nil, nil)
            }
            KeychainHelper.delete(forKey: accessTokenKey)
            KeychainHelper.delete(forKey: refreshTokenKey)
        }
    )
}

extension DependencyValues {
    var tokenClient: TokenClient {
        get { self[TokenClient.self] }
        set { self[TokenClient.self] = newValue }
    }
}
