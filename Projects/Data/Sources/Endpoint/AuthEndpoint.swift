//
//  AuthEndpoint.swift
//  Data
//
//  Created by 진준호 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Foundation

enum AuthEndpoint: APIEndpoint {
    case login(deviceID: String)
    case refresh(refreshToken: String)

    var path: String {
        switch self {
        case .login:
            "/api/v1/auth/login"
        case .refresh:
            "/api/v1/auth/refresh"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .refresh: .post
        }
    }

    var body: Encodable? {
        switch self {
        case let .login(deviceID):
            ["device_id": deviceID]
        case let .refresh(refreshToken):
            ["refresh_token": refreshToken]
        }
    }

    var requiresAuth: Bool {
        false
    }
}
