//
//  HomeEndpoint.swift
//  Data
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Foundation

enum HomeEndpoint: APIEndpoint {
    case card
    case seasonalRecords

    var path: String {
        switch self {
        case .card: "/api/v1/home/card"
        case .seasonalRecords: "/api/v1/home/seasonal-records"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .card: .get
        case .seasonalRecords: .get
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .card: true
        case .seasonalRecords: true
        }
    }
}
