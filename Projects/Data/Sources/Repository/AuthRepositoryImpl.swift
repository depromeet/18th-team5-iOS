//
//  AuthRepositoryImpl.swift
//  Data
//
//  Created by 진준호 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

// MARK: - DependencyKey

extension AuthRepository: @retroactive DependencyKey {
    public static let liveValue: AuthRepository = AuthRepositoryImpl.live()
}

// MARK: - liveValue

enum AuthRepositoryImpl {
    static func live() -> AuthRepository {
        @Dependency(\.networkClient) var networkClient
        @Dependency(\.deviceIDClient) var deviceIDClient
        @Dependency(\.tokenClient) var tokenClient
        return AuthRepository(
            isSignin: {
                tokenClient.getRefreshToken() != nil
            },
            login: {
                do {
                    let deviceID = deviceIDClient.getDeviceID() ?? deviceIDClient.createDeviceID()
                    let response: AuthTokenDTO? = try await networkClient.request(
                        AuthEndpoint.login(deviceID: deviceID), retryCount: 2
                    )

                    guard let response else {
                        throw DomainError.unknown("데이터 획득 실패")
                    }

                    tokenClient.saveTokens(
                        response.accessToken,
                        response.refreshToken
                    )
                } catch {
                    throw mapToDomainError(error)
                }
            },
            logout: {
                tokenClient.clearTokens()
            }
        )
    }
}
