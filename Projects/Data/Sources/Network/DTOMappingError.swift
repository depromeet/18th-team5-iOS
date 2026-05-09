//
//  DTOMappingError.swift
//  Data
//
//  Created by 진준호 on 4/20/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// DTO → Domain 변환 시 발생하는 매핑 에러
enum DTOMappingError: Error {
    case invalidDateFormat(String)
    case invalidValue(String)
}
