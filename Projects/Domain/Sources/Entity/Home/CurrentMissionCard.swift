//
//  CurrentMissionCard.swift
//  Domain
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//
import Foundation

public struct CurrentMissionCard: Equatable {
    public let id: Int
    public let title: String
    public let participantCount: Int
    public let missionType: String
    public let isCompleted: Bool

    public init(id: Int, title: String, participantCount: Int, missionType: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.participantCount = participantCount
        self.missionType = missionType
        self.isCompleted = isCompleted
    }
}
