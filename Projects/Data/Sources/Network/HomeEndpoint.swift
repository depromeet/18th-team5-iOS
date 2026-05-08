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
    case fetchHome

    var path: String {
        "/api/v1/home/card"
    }

    var method: HTTPMethod {
        .get
    }
}
