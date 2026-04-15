//
//  ExampleDetail.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// 복잡한 Entity 예시 - Optional, 중첩 타입, Date 포함
public struct ExampleDetail: Equatable {
    public let id: Int
    public let title: String
    public let content: String
    public let category: Category
    public let tags: [String]
    public let imageURL: URL?
    public let createdAt: Date

    public init(
        id: Int,
        title: String,
        content: String,
        category: Category,
        tags: [String],
        imageURL: URL?,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.tags = tags
        self.imageURL = imageURL
        self.createdAt = createdAt
    }
}

public extension ExampleDetail {
    /// 중첩 enum 예시
    enum Category: String, Equatable {
        case general
        case important
        case archived
    }
}
