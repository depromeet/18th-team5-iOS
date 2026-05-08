//
//  TokenRepositoryImpl.swift
//  Data
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Core
import Dependencies
import Domain
import Foundation

// MARK: - DependencyKey

extension TokenRepository: @retroactive DependencyKey {
    public static let liveValue: TokenRepository = TokenRepositoryImpl.live()
}

// MARK: - liveValue

enum TokenRepositoryImpl {
    static func live() -> TokenRepository {
        TokenRepository(
            hasTokens: {
                @Dependency(\.tokenClient) var tokenClient
                return tokenClient.getAccessToken() != nil && tokenClient.getRefreshToken() != nil
            },
            setDebugDeviceToken: { token in
                let env = Bundle.main.infoDictionary?["Environment"] as? String
                guard env == "Dev" else {
                    preconditionFailure("setDebugDeviceToken is only available in Dev environment")
                }
                KeychainHelper.save(data: token.data(using: .utf8)!, forKey: .deviceID)
            }
        )
    }
}
