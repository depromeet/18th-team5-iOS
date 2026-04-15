//
//  NetworkClient.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Core
import Foundation

final class NetworkClient {
    static let shared = NetworkClient()
    private let session: Session

    private init(session: Session = .default) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        do {
            return try await session.request(endpoint)
                .validate(statusCode: 200 ..< 300)
                .serializingDecodable(T.self)
                .value
        } catch let afError as AFError {
            throw afError.toNetworkError()
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
    }
}

private extension AFError {
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
