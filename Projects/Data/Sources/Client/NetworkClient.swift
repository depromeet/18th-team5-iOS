//
//  NetworkClient.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Dependencies
import DependenciesMacros
import Foundation

/// @DependencyClient 매크로가 제네릭 메서드를 지원하지 않으므로 Data를 반환하고, 편의 메서드에서 디코딩
@DependencyClient
struct NetworkClient: Sendable {
    var requestData: @Sendable (_ endpoint: any APIEndpoint) async throws -> Data
    var requestEmpty: @Sendable (_ endpoint: any APIEndpoint) async throws -> Void
}

// MARK: - 편의 디코딩 메서드

extension NetworkClient {
    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    func request<T: Decodable>(_ endpoint: any APIEndpoint) async throws -> T {
        let data = try await requestData(endpoint)
        do {
            return try Self.makeDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

// MARK: - DependencyKey

extension NetworkClient: DependencyKey {
    static let liveValue = NetworkClient(
        requestData: { endpoint in
            try await performRequest(endpoint: endpoint)
        },
        requestEmpty: { endpoint in
            _ = try await performRequest(endpoint: endpoint, emptyResponseCodes: [200, 204, 205])
        }
    )

    /// requestData/requestEmpty 공통 네트워크 요청 로직
    private static func performRequest(
        endpoint: any APIEndpoint,
        emptyResponseCodes: Set<Int> = []
    ) async throws -> Data {
        let urlRequest = try endpoint.asURLRequest()
        let interceptor: AuthInterceptor? = endpoint.requiresAuth ? .shared : nil
        do {
            return try await AF.request(urlRequest, interceptor: interceptor)
                .validate(statusCode: 200 ..< 300)
                .serializingData(emptyResponseCodes: emptyResponseCodes)
                .value
        } catch let afError as AFError {
            throw afError.toNetworkError()
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
    }
}

extension DependencyValues {
    var networkClient: NetworkClient {
        get { self[NetworkClient.self] }
        set { self[NetworkClient.self] = newValue }
    }
}

// MARK: - AFError 변환

extension AFError {
    func toNetworkError() -> NetworkError {
        switch self {
        case let .responseValidationFailed(reason):
            if case let .unacceptableStatusCode(code) = reason {
                return .requestFailed(statusCode: code)
            }
            return .requestFailed(statusCode: -1)
        case .responseSerializationFailed:
            return .decodingFailed
        case let .sessionTaskFailed(error):
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                return .networkUnavailable
            }
            return .unknown(error.localizedDescription)
        default:
            return .unknown(localizedDescription)
        }
    }
}
