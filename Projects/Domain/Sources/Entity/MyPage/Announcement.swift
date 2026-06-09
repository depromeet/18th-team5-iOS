//
//  Announcement.swift
//  Domain
//
//  Created by 이정원 on 6/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct Announcement: Equatable {
    public let title: String
    public let content: String
    public let date: Date

    public init(
        title: String,
        content: String,
        date: Date
    ) {
        self.title = title
        self.content = content
        self.date = date
    }
}
