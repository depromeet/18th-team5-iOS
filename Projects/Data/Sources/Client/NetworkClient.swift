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
            let response = try Self.makeDecoder().decode(BaseResponse<T>.self, from: data)
            return response.data
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

    /// 서버 에러 응답 디코딩용 내부 타입
    private struct ErrorResponse: Decodable {
        let code: String
        let message: String
    }

    /// requestData/requestEmpty 공통 네트워크 요청 로직
    private static func performRequest(
        endpoint: any APIEndpoint,
        emptyResponseCodes: Set<Int> = []
    ) async throws -> Data {
        let urlRequest = try endpoint.asURLRequest()
        let interceptor: AuthInterceptor? = endpoint.requiresAuth ? .shared : nil

        do {
            return try await AF.request(urlRequest, interceptor: interceptor)
                .validate { _, response, data in
                    Self.validateResponse(response: response, data: data)
                }
                .serializingData(emptyResponseCodes: emptyResponseCodes)
                .value
        } catch let afError as AFError {
            // Custom validation 실패 시 원본 에러(ServerDomainError / NetworkError) 추출
            if case let .responseValidationFailed(reason) = afError,
               case let .customValidationFailed(underlyingError) = reason {
                throw underlyingError
            }
            throw afError.toNetworkError()
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
    }

    // MARK: - Validation

    /// 서버 응답을 검증합니다.
    /// - 2xx: 통과
    /// - 401: 서버 에러 코드를 파싱하여 실패 처리 → AuthInterceptor.retry()에서 분기
    /// - 기타 non-2xx: 서버 에러 코드 파싱 시도 후 실패 처리
    private static func validateResponse(
        response: HTTPURLResponse,
        data: Data?
    ) -> DataRequest.ValidationResult {
        switch response.statusCode {
        case 200 ..< 300:
            return .success(())
        default:
            if let data,
               let body = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                return .failure(ServerDomainError.from(code: body.code, message: body.message))
            }
            return .failure(NetworkError.requestFailed(statusCode: response.statusCode))
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
