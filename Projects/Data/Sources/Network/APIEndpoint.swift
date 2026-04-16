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

    /// 각 Endpoint에서 concrete 타입을 직접 인코딩하므로 타입 이레이저 불필요
    func encodedBodyData() throws -> Data?
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

    func encodedBodyData() throws -> Data? {
        nil
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
        request.headers = headers ?? .default

        do {
            if let bodyData = try encodedBodyData() {
                request.httpBody = bodyData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw NetworkError.encodingFailed
        }

        return request
    }
}
