//
//  MissionSearchGuideClient.swift
//  Domain
//
//  Created by 이정원 on 5/29/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct MissionSearchGuideClient: Sendable {
    public var lastGuidedDate: @Sendable () -> Date?
    public var setLastGuidedDate: @Sendable (_ date: Date) -> Void
}

extension MissionSearchGuideClient: TestDependencyKey {
    public static let testValue = MissionSearchGuideClient()
}

public extension DependencyValues {
    var missionSearchGuideClient: MissionSearchGuideClient {
        get { self[MissionSearchGuideClient.self] }
        set { self[MissionSearchGuideClient.self] = newValue }
    }
}
