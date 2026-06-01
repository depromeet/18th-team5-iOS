//
//  SolarTermIntroContent.swift
//  Domain
//
//  Created by 송민교 on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct SolarTermIntroContent: Equatable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let imageURLs: [String]
    public let body: String

    public init(
        id: String,
        title: String,
        subtitle: String,
        imageURLs: [String],
        body: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageURLs = imageURLs
        self.body = body
    }
}
