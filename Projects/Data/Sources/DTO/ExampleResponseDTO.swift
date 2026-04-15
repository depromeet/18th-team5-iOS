//
//  ExampleResponseDTO.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

/// 목록 조회 응답 DTO 예시 - 간단한 필드 매핑
struct ExampleItemResponseDTO: Decodable {
    let id: Int
    let title: String
    let isCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case isCompleted = "is_completed"
    }
}

extension ExampleItemResponseDTO {
    func toDomain() -> ExampleItem {
        ExampleItem(
            id: id,
            title: title,
            isCompleted: isCompleted
        )
    }
}

/// 상세 조회 응답 DTO 예시 - 중첩 구조, Optional, Date 변환 포함
struct ExampleDetailResponseDTO: Decodable {
    let id: Int
    let title: String
    let content: String
    let category: String
    let tags: [String]
    let imageURL: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case category
        case tags
        case imageURL = "image_url"
        case createdAt = "created_at"
    }
}

extension ExampleDetailResponseDTO {
    func toDomain() -> ExampleDetail {
        let dateFormatter = ISO8601DateFormatter()

        return ExampleDetail(
            id: id,
            title: title,
            content: content,
            category: ExampleDetail.Category(rawValue: category) ?? .general,
            tags: tags,
            imageURL: imageURL.flatMap { URL(string: $0) },
            createdAt: dateFormatter.date(from: createdAt) ?? Date()
        )
    }
}
