//
//  UserEndpoint.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Foundation

enum UserEndpoint: APIEndpoint {
    case fetchUsers
    case fetchUser(id: Int)

    var path: String {
        switch self {
        case .fetchUsers:
            return "/users"
        case let .fetchUser(id):
            return "/users/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchUsers, .fetchUser:
            return .get
        }
    }
}
