//
//  AnnouncementEndpoint.swift
//  Data
//
//  Created by 이정원 on 6/10/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire

enum AnnouncementEndpoint: APIEndpoint {
    case fetchAnnouncements
    case fetchAnnouncement(Int)

    var path: String {
        switch self {
        case .fetchAnnouncements:
            "/api/announcements"
        case let .fetchAnnouncement(id):
            "/api/announcements/\(id)"
        }
    }

    var method: HTTPMethod {
        .get
    }
}
