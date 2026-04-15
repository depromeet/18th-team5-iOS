//
//  NetworkError.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// Data 계층 내부에서만 사용하는 네트워크 에러 타입
enum NetworkError: Error, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case networkUnavailable
    case unknown(String)
}
