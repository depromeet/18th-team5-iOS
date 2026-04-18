//
//  ExampleItem.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct ExampleItem: Equatable {
    public let id: Int
    public let title: String
    public let isCompleted: Bool

    public init(id: Int, title: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
