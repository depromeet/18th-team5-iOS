//
//  AuthInterceptor.swift
//  Data
//
//  Created by 진준호 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Dependencies
import Foundation

final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    static let shared = AuthInterceptor()

    @Dependency(\.tokenClient) private var tokenClient
    @Dependency(\.networkClient) private var networkClient
    @Dependency(\.deviceIDClient) private var deviceIDClient

    private let lock = NSLock()
    private var isRefreshing = false
    private var pendingCompletions: [(RetryResult) -> Void] = []

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
        completion(.success(request))
    }

    func retry(
        _ request: Request,
        for _: Session,
        dueTo _: any Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }

        lock.lock()
        pendingCompletions.append(completion)

        guard !isRefreshing else {
            lock.unlock()
            return
        }

        isRefreshing = true
        lock.unlock()

        Task { [weak self] in
            guard let self else { return }

            let result = await refreshToken()

            lock.lock()
            let completions = pendingCompletions
            pendingCompletions = []
            isRefreshing = false
            lock.unlock()

            completions.forEach { $0(result) }
        }
    }

    // MARK: - 토큰 갱신 전략: refresh → deviceID 재로그인 → 실패

    private func refreshToken() async -> RetryResult {
        if let token = tokenClient.getRefreshToken() {
            do {
                let response: AuthTokenDTO = try await networkClient.request(
                    AuthEndpoint.refresh(refreshToken: token)
                )
                tokenClient.saveTokens(response.accessToken, response.refreshToken)
                return .retry
            } catch {
                assertionFailure("토큰 갱신 실패: \(error)")
            }
        }

        do {
            let deviceID = deviceIDClient.getDeviceID()
            let response: AuthTokenDTO = try await networkClient.request(
                AuthEndpoint.login(deviceID: deviceID)
            )
            tokenClient.saveTokens(response.accessToken, response.refreshToken)
            return .retry
        } catch {
            return .doNotRetry
        }
    }
}
