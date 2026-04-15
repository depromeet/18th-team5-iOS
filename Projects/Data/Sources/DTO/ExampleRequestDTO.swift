//
//  ExampleRequestDTO.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

/// POST 요청 Body DTO 예시 - Encodable 사용
struct CreateExampleRequestDTO: Encodable {
    let title: String
    let content: String
    let category: String
}

/// PUT 요청 Body DTO 예시
struct UpdateExampleRequestDTO: Encodable {
    let title: String
    let isCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case title
        case isCompleted = "is_completed"
    }
}
