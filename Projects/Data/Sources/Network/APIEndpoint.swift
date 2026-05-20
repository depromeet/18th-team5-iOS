//
//  APIEndpoint.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Foundation

protocol APIEndpoint: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var queryItems: [URLQueryItem]? { get }

    /// body가 있는 경우 Encodable 타입을 반환하면 extension에서 자동 인코딩
    var body: Encodable? { get }

    /// 인증 토큰이 필요한 엔드포인트 여부 (기본값: true)
    var requiresAuth: Bool { get }
}

extension APIEndpoint {
    var baseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String,
              !url.isEmpty else {
            assertionFailure("Info.plist에 BaseURL이 설정되지 않았습니다. 빌드 설정을 확인하세요.")
            return ""
        }
        return url
    }

    var headers: HTTPHeaders? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Encodable? {
        nil
    }

    var requiresAuth: Bool {
        true
    }

    func asURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        urlComponents.path += path

        if let queryItems, !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.method = method

        var merged = HTTPHeaders.default
        headers?.forEach { merged.add($0) }
        request.headers = merged

        if let body {
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(AnyEncodable(body))
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw NetworkError.encodingFailed
            }
        }

        return request
    }
}

// MARK: - Encodable 타입 이레이저

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init(_ value: Encodable) {
        self.encodeClosure = value.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
