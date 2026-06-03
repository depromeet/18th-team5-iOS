//
//  MissionSearchGuideClientImpl.swift
//  Data
//
//  Created by 이정원 on 5/29/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

extension MissionSearchGuideClient: @retroactive DependencyKey {
    public static let liveValue: MissionSearchGuideClient = MissionSearchGuideClientImpl.live()
}

public enum MissionSearchGuideClientImpl {
    private static let lastGuidedDateKey = "missionSearch.lastGuidedDate"

    public static func live() -> MissionSearchGuideClient {
        MissionSearchGuideClient(
            lastGuidedDate: {
                UserDefaults.standard.object(forKey: lastGuidedDateKey) as? Date
            },
            setLastGuidedDate: { date in
                UserDefaults.standard.set(date, forKey: lastGuidedDateKey)
            }
        )
    }
}
