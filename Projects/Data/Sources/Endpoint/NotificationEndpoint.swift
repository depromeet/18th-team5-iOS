//
//  NotificationEndpoint.swift
//  Data
//
//  Created by 이정원 on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire

enum NotificationEndpoint: APIEndpoint {
    case fetchNotificaitonInfo

    var path: String {
        switch self {
        case .fetchNotificaitonInfo:
            "/api/v1/notifications/settings"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchNotificaitonInfo: .get
        }
    }
}
