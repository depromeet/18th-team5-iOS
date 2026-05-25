//
//  MainFeature.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct MainFeature {
    @ObservableState
    public struct State: Equatable {
        public var tab: Tab = .home
        var home: HomeFeature.State = .init()
        @Presents var missionRecord: MissionRecordFeature.State?

        public init() {}
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case home(HomeFeature.Action)
        case missionRecord(PresentationAction<MissionRecordFeature.Action>)
    }

    @Dependency(\.logger) var logger

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: 로깅 테스트용 호출입니다. 추후 제거부탁드립니다.
                logger.debug(message: "MainView did appear")
                return .none

            case let .home(.delegate(.navigateToMissionCamera(missionId, title, missionTypeRaw, solarTermId))):
                let missionType = MissionType(rawValue: missionTypeRaw) ?? {
                    assertionFailure("Unknown missionType: \(missionTypeRaw)")
                    return .daily
                }()
                state.missionRecord = MissionRecordFeature.State(
                    missionId: missionId,
                    missionTitle: title,
                    missionType: missionType,
                    solarTermId: solarTermId
                )
                return .none

            case .home(.delegate(.navigateToMissionTab)):
                // TODO: 미션 추천 페이지 이동 - @minkyo
                return .none

            case .missionRecord(.presented(.delegate(.dismiss))):
                state.missionRecord = nil
                return .none

            case .missionRecord(.presented(.delegate(.submitted))):
                state.missionRecord = nil
                return .none

            case .missionRecord:
                return .none

            case .home, .binding:
                return .none
            }
        }
        .ifLet(\.$missionRecord, action: \.missionRecord) {
            MissionRecordFeature()
        }
    }
}

public extension MainFeature {
    enum Tab: CaseIterable {
        case home
        case archive
        case myPage
    }
}
