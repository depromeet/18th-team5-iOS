//
//  MissionListFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct MissionListFeature {
    @ObservableState
    public struct State: Equatable {
        var userType: UserType = .explorer
        var solarTerm: SolarTerm = .ibha
        var isTooltipPresented: Bool = true
        var isIndicatorEnabled: Bool = false

        var missions: [Mission]
        var selectedMission: Mission
        @Presents var search: MissionSearchFeature.State?

        public init() {
            let missions: [Mission] = .mock
            self.missions = missions
            self.selectedMission = missions[1]
        }

        var isSearchMissionButtonEnabled: Bool {
            // TODO: 추후 로직 구현
            true
        }

        var category: MissionCategory {
            selectedMission.category
        }

        var selectedIndex: Int? {
            missions.firstIndex(of: selectedMission)
        }
    }

    public enum Action: BindableAction {
        case categoryTapped(MissionCategory)
        case indicatorIndexChanged(Int)
        case searchMissionButtonTapped
        case binding(BindingAction<State>)
        case search(PresentationAction<MissionSearchFeature.Action>)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case let .categoryTapped(category):
                let mission = state.missions.first { $0.category == category }
                guard let mission else { return .none }
                state.selectedMission = mission
                return .none
            case let .indicatorIndexChanged(index):
                guard state.missions.indices.contains(index) else { return .none }
                state.selectedMission = state.missions[index]
                return .none
            case .searchMissionButtonTapped:
                state.search = .init(season: state.solarTerm.season)
                return .none
            case .binding: return .none
            case .search: return .none
            }
        }
        .ifLet(\.$search, action: \.search) {
            MissionSearchFeature()
        }
    }
}

private extension [Mission] {
    static let mock: [Mission] = [
        .init(
            id: 0,
            title: "음식 관련 미션 예시입니다 1",
            category: .food,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 1,
            title: "음식 관련 미션 예시입니다 2",
            category: .food,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 2,
            title: "음식 관련 미션 예시입니다 3",
            category: .food,
            season: .summer,
            isCompleted: true
        ),
        .init(
            id: 3,
            title: "음식 관련 미션 예시입니다 4",
            category: .food,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 4,
            title: "음식 관련 미션 예시입니다 5",
            category: .food,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 5,
            title: "콘텐츠 관련 미션 예시입니다 1",
            category: .contents,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 6,
            title: "콘텐츠 관련 미션 예시입니다 2",
            category: .contents,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 7,
            title: "콘텐츠 관련 미션 예시입니다 3",
            category: .contents,
            season: .summer,
            isCompleted: true
        ),
        .init(
            id: 8,
            title: "콘텐츠 관련 미션 예시입니다 4",
            category: .contents,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 9,
            title: "콘텐츠 관련 미션 예시입니다 5",
            category: .contents,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 10,
            title: "활동 관련 미션 예시입니다 1",
            category: .activity,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 11,
            title: "활동 관련 미션 예시입니다 2",
            category: .activity,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 12,
            title: "활동 관련 미션 예시입니다 3",
            category: .activity,
            season: .summer,
            isCompleted: true
        ),
        .init(
            id: 13,
            title: "활동 관련 미션 예시입니다 4",
            category: .activity,
            season: .summer,
            isCompleted: false
        ),
        .init(
            id: 14,
            title: "활동 관련 미션 예시입니다 5",
            category: .activity,
            season: .summer,
            isCompleted: false
        )
    ]
}
