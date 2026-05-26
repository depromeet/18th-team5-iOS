//
//  Mission.swift
//  Domain
//
//  Created by 이정원 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct Mission: Equatable, Hashable {
    public let id: Int
    public let title: String
    public let description: String?
    public let theme: MissionTheme?
    public let attribute: MissionAttribute?
    public let isCompleted: Bool?

    public init(
        id: Int,
        title: String,
        description: String? = nil,
        theme: MissionTheme? = nil,
        attribute: MissionAttribute? = nil,
        isCompleted: Bool? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.theme = theme
        self.attribute = attribute
        self.isCompleted = isCompleted
    }
}
