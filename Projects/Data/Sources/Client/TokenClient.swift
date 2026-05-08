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
    private static let storage = OSAllocatedUnfairLock<(access: String?, refresh: String?)>(
        initialState: (nil, nil)
    )

    static let liveValue = {
        @Dependency(\.logger) var logger
        return TokenClient(
            getAccessToken: {
                storage.withLock { state in
                    if let token = state.access { return token }

                    if let data = KeychainHelper.load(forKey: .accessToken),
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

                    if let data = KeychainHelper.load(forKey: .refreshToken),
                       let token = String(data: data, encoding: .utf8) {
                        state.refresh = token
                        return token
                    }

                    return nil
                }
            },
            saveTokens: { accessToken, refreshToken in
                storage.withLock { state in
                    if let data = accessToken.data(using: .utf8) {
                        if !KeychainHelper.save(data: data, forKey: .accessToken) {
                            logger.error(message: "AccessToken Keychain 저장 실패")
                        }
                    }
                    if let data = refreshToken.data(using: .utf8) {
                        if !KeychainHelper.save(data: data, forKey: .refreshToken) {
                            logger.error(message: "RefreshToken Keychain 저장 실패")
                        }
                    }
                    state = (accessToken, refreshToken)
                }
            },
            clearTokens: {
                storage.withLock { state in
                    if !KeychainHelper.delete(forKey: .accessToken) {
                        logger.error(message: "AccessToken Keychain 삭제 실패")
                    }
                    if !KeychainHelper.delete(forKey: .refreshToken) {
                        logger.error(message: "RefreshToken Keychain 삭제 실패")
                    }
                    state = (nil, nil)
                }
            }
        )
    }()
}

extension DependencyValues {
    var tokenClient: TokenClient {
        get { self[TokenClient.self] }
        set { self[TokenClient.self] = newValue }
    }
}
