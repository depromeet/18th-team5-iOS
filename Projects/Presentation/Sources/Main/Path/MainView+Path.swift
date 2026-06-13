//
//  MainView+Path.swift
//  Presentation
//
//  Created by 이정원 on 6/2/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

extension MainView {
    @ViewBuilder
    func pathView(store: StoreOf<MainFeature.Path>) -> some View {
        switch store.case {
        case let .myPage(store): MyPageView(store: store)
        case let .solarTermIntroContent(store): SolarTermIntroContentView(store: store)
        case let .missionRecord(store): MissionRecordView(store: store)
        case let .freeRecord(store): FreeRecordView(store: store)
        }
    }
}
