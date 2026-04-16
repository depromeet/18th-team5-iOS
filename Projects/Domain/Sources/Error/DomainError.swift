//
//  DomainError.swift
//  Domain
//
//  Created by 진준호 on 4/15/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public enum DomainError: Error, Equatable, Sendable {
    /// 인증이 필요하거나 만료된 경우 (401)
    case unauthorized
    /// 권한이 없는 리소스에 접근한 경우 (403)
    case forbidden
    /// 요청한 리소스를 찾을 수 없는 경우 (404)
    case notFound
    /// 잘못된 요청 데이터 (400, 422 등)
    case invalidRequest(String?)
    /// 서비스를 이용할 수 없는 경우 (네트워크 끊김, 서버 점검 등)
    case serviceUnavailable
    /// 서버 응답 데이터를 처리할 수 없는 경우
    case dataCorrupted
    /// 서버 내부 오류 (500번대)
    case serverError
    /// 분류되지 않은 오류
    case unknown(String)
}
