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
    case logout

    var path: String {
        switch self {
        case .login:
            "/api/v1/auth/login"
        case .refresh:
            "/api/v1/auth/refresh"
        case .logout:
            "/api/v1/auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .refresh, .logout: .post
        }
    }

    var body: Encodable? {
        switch self {
        case let .login(deviceID):
            ["deviceUuid": deviceID]
        case let .refresh(refreshToken):
            ["refreshToken": refreshToken]
        case .logout:
            nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login, .refresh: false
        case .logout: true
        }
    }
}
