//
//  ExampleResponseDTO.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

struct ExampleItemResponseDTO: Decodable {
    let id: Int
    let title: String
    let isCompleted: Bool
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

struct ExampleDetailResponseDTO: Decodable {
    let id: Int
    let title: String
    let content: String
    let category: String
    let tags: [String]
    let imageUrl: String?
    let createdAt: String
}

extension ExampleDetailResponseDTO {
    private static let iso8601Formatter = ISO8601DateFormatter()

    func toDomain() throws -> ExampleDetail {
        guard let parsedDate = Self.iso8601Formatter.date(from: createdAt) else {
            throw NetworkError.decodingFailed
        }

        return ExampleDetail(
            id: id,
            title: title,
            content: content,
            category: ExampleDetail.Category(rawValue: category) ?? .general,
            tags: tags,
            imageURL: imageUrl.flatMap { URL(string: $0) },
            createdAt: parsedDate
        )
    }
}
