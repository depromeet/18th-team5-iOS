//
//  TokenClient.swift
//  Data
//
//  Created by 진준호 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation
import os

@DependencyClient
struct TokenClient: Sendable {
    var getAccessToken: @Sendable () -> String? = { nil }
    var getRefreshToken: @Sendable () -> String? = { nil }
    var saveTokens: @Sendable (_ accessToken: String, _ refreshToken: String) -> Void
}

// MARK: - DependencyKey

extension TokenClient: DependencyKey {
    private static let storage = OSAllocatedUnfairLock<(access: String?, refresh: String?)>(
        initialState: (nil, nil)
    )

    static let liveValue = TokenClient(
        getAccessToken: {
            storage.withLock { $0.access }
        },
        getRefreshToken: {
            storage.withLock { $0.refresh }
        },
        saveTokens: { accessToken, refreshToken in
            storage.withLock { state in
                state = (accessToken, refreshToken)
            }
        }
    )
}

extension DependencyValues {
    var tokenClient: TokenClient {
        get { self[TokenClient.self] }
        set { self[TokenClient.self] = newValue }
    }
}
