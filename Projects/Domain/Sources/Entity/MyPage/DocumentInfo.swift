//
//  DocumentInfo.swift
//  Domain
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct DocumentInfo: Equatable {
    public let title: String?
    public let content: String

    public init(title: String?, content: String) {
        self.title = title
        self.content = content
    }
}
