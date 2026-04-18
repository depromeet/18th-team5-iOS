//
//  ExampleDetail.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

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
    enum Category: String, Equatable {
        case general
        case important
        case archived
    }
}
