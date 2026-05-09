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
            setDebugDeviceToken: { token in
                @Dependency(\.logger) var logger
                @Dependency(\.deviceIDClient) var deviceIDClient

                let env = Bundle.main.infoDictionary?["Environment"] as? String
                guard env == "Dev" else {
                    preconditionFailure("setDebugDeviceToken is only available in Dev environment")
                }

                let result = deviceIDClient.setDeviceID(token)
                if result == false {
                    logger.error(message: "DebugToken 저장 실패")
                }
                return result
            }
        )
    }
}
