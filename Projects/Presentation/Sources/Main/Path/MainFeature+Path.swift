//
//  MainFeature+Path.swift
//  Presentation
//
//  Created by 이정원 on 6/2/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

extension MainFeature {
    @Reducer
    public enum Path {
        case myPage(MyPageFeature)
        case solarTermIntroContent(SolarTermIntroContentFeature)
        case missionRecord(MissionRecordFeature)
        case freeRecord(FreeRecordFeature)
    }
}

extension MainFeature.Path.State: Equatable {}
