//
//  AuthInterceptor.swift
//  Data
//
//  Created by 진준호 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Core
import Dependencies
import Foundation
import os

final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    static let shared = AuthInterceptor()

    @Dependency(\.tokenClient) private var tokenClient
    @Dependency(\.networkClient) private var networkClient
    @Dependency(\.deviceIDClient) private var deviceIDClient
    @Dependency(\.logger) private var logger

    private let state = OSAllocatedUnfairLock(
        initialState: (isRefreshing: false, pendingCompletions: [(RetryResult) -> Void]())
    )

    private init() {}

    func adapt(
        _ urlRequest: URLRequest,
        for _: Session,
        completion: @escaping (Result<URLRequest, any Error>) -> Void
    ) {
        var request = urlRequest
        if let token = tokenClient.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        logger.debug(message: "\n\n🟢[REQUEST]\n\(request.curlString)\n")
        completion(.success(request))
    }

    func retry(
        _ request: Request,
        for _: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }

        // AUTH_401_* 에러: refresh token이 만료/무효하므로 재시도 불가
        if let serverError = extractServerDomainError(from: error),
           serverError.isAuthRefreshError {
            completion(.doNotRetry)
            return
        }

        let shouldStart = state.withLock { state in
            state.pendingCompletions.append(completion)
            guard !state.isRefreshing else { return false }
            state.isRefreshing = true
            return true
        }

        guard shouldStart else { return }

        Task { [weak self] in
            guard let self else { return }

            let result = await refreshToken()

            let completions = state.withLock { state in
                let pending = state.pendingCompletions
                state.pendingCompletions = []
                state.isRefreshing = false
                return pending
            }

            completions.forEach { $0(result) }
        }
    }

    // MARK: - 에러 추출

    /// Alamofire AFError에 래핑된 ServerDomainError를 추출합니다.
    private func extractServerDomainError(from error: Error) -> ServerDomainError? {
        guard let afError = error.asAFError,
              case let .responseValidationFailed(reason) = afError,
              case let .customValidationFailed(underlyingError) = reason,
              let serverError = underlyingError as? ServerDomainError else {
            return nil
        }
        return serverError
    }

    // MARK: - 토큰 갱신 전략: refresh → deviceID 재로그인 → 실패

    private func refreshToken() async -> RetryResult {
        if let token = tokenClient.getRefreshToken() {
            do {
                let response: AuthTokenDTO? = try await networkClient.request(
                    AuthEndpoint.refresh(refreshToken: token)
                )

                if let response {
                    tokenClient.saveTokens(response.accessToken, response.refreshToken)
                    return .retry
                } else {
                    logger.error(message: "토큰 갱신 실패: 토큰을 획득할 수 없음")
                }
            } catch {
                logger.error(message: "토큰 갱신 실패: \(error)")
            }
        }

        do {
            let deviceID = deviceIDClient.getDeviceID() ?? deviceIDClient.createDeviceID()
            let response: AuthTokenDTO? = try await networkClient.request(
                AuthEndpoint.login(deviceID: deviceID)
            )
            if let response {
                tokenClient.saveTokens(response.accessToken, response.refreshToken)
                return .retry
            } else {
                logger.error(message: "토큰 갱신 실패: 토큰을 획득할 수 없음")
                return .doNotRetry
            }
        } catch {
            logger.error(message: "토큰 갱신 실패: \(error)")
            return .doNotRetry
        }
    }
}
