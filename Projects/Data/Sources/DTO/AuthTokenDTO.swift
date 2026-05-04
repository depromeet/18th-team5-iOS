//
//  AuthTokenDTO.swift
//  Data
//
//  Created by 진준호 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

struct AuthTokenDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}
