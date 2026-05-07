//
//  BaseResponse.swift
//  Data
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let code: String
    let message: String
    let data: T
}
