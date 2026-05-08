//
//  MissionCompletion.swift
//  Domain
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct MissionCompletion: Equatable, Identifiable, Sendable {
    public var id: Int {
        completionId
    }

    public let completionId: Int
    public let missionId: Int
    public let missionType: MissionType
    public let objectKey: String?
    public let presignedImageUrl: URL?
    public let memo: String?
    public let completedAt: Date

    public init(
        completionId: Int,
        missionId: Int,
        missionType: MissionType,
        objectKey: String?,
        presignedImageUrl: URL?,
        memo: String?,
        completedAt: Date
    ) {
        self.completionId = completionId
        self.missionId = missionId
        self.missionType = missionType
        self.objectKey = objectKey
        self.presignedImageUrl = presignedImageUrl
        self.memo = memo
        self.completedAt = completedAt
    }
}
