//
//  NotificationEndpoint.swift
//  Data
//
//  Created by 이정원 on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire

enum NotificationEndpoint: APIEndpoint {
    case fetchNotificaitonSettings
    case setNotificationSettings(NotificationSettingsRequestDTO)

    var path: String {
        switch self {
        case .fetchNotificaitonSettings, .setNotificationSettings:
            "/api/v1/notifications/settings"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchNotificaitonSettings: .get
        case .setNotificationSettings: .put
        }
    }

    var body: Encodable? {
        switch self {
        case .fetchNotificaitonSettings: nil
        case let .setNotificationSettings(body): body
        }
    }
}
