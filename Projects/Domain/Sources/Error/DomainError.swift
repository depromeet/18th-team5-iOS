//
//  DomainError.swift
//  Domain
//
//  Created by 진준호 on 4/15/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// 도메인 계층에서 사용하는 공통 에러 타입
public enum DomainError: Error, Equatable {
    case invalidRequest
    case serverError(statusCode: Int)
    case decodingFailed
    case networkUnavailable
    case unknown(String)
}
