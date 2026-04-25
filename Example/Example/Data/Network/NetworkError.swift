//
//  NetworkError.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case encodingFailed
    case requestFailed(statusCode: Int)
    case decodingFailed
    case networkUnavailable
    case unknown(String)
}
