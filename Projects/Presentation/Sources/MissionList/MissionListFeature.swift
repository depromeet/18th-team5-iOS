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
    @Dependency(\.missionRepository) private var missionRepository

    @ObservableState
    public struct State: Equatable {
        var userType: UserType = .explorer
        var solarTerm: SolarTerm = .ibha
        var isTooltipPresented: Bool = true
        var isIndicatorEnabled: Bool = false

        var missions: [Mission]
        var selectedMission: Mission
        var searchedMission: Mission?

        @Presents var search: MissionSearchFeature.State?
        @Presents var searchResult: MissionSearchResultFeature.State?

        public init() {
            let missions: [Mission] = .mock
            self.missions = missions
            self.selectedMission = missions[1]
        }

        var isSearchMissionButtonEnabled: Bool {
            // TODO: 추후 로직 구현
            true
        }

        var season: Season {
            solarTerm.season
        }

        var theme: MissionTheme? {
            selectedMission.theme
        }

        var selectedIndex: Int? {
            missions.firstIndex(of: selectedMission)
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case themeTapped(MissionTheme)
        case indicatorIndexChanged(Int)
        case searchMissionButtonTapped
        case searchResultFetched(Mission?)
        case binding(BindingAction<State>)
        case search(PresentationAction<MissionSearchFeature.Action>)
        case searchResult(PresentationAction<MissionSearchResultFeature.Action>)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.searchedMission == nil else { return .none }
                return .run { send in
                    await fetchSearchedMission(send)
                }
            case let .themeTapped(theme):
                let mission = state.missions.first { $0.theme == theme }
                guard let mission else { return .none }
                state.selectedMission = mission
                return .none
            case let .indicatorIndexChanged(index):
                guard state.missions.indices.contains(index) else { return .none }
                state.selectedMission = state.missions[index]
                return .none
            case .searchMissionButtonTapped:
                if let mission = state.searchedMission {
                    state.searchResult = .init(mission)
                } else {
                    state.search = .init(season: state.solarTerm.season)
                }
                return .none
            case let .searchResultFetched(mission):
                guard let mission else { return .none }
                state.searchedMission = mission
                state.searchResult = .init(mission)
                return .none
            case let .search(.presented(.delegate(.searchMission(attribute)))):
                state.search = nil
                return .run { send in
                    await searchMission(attribute, send)
                }
            case .binding: return .none
            case .search: return .none
            case .searchResult: return .none
            }
        }
        .ifLet(\.$search, action: \.search) {
            MissionSearchFeature()
        }
        .ifLet(\.$searchResult, action: \.searchResult) {
            MissionSearchResultFeature()
        }
    }
}

private extension MissionListFeature {
    func fetchSearchedMission(_ send: Send<Action>) async {
        do {
            let mission = try await missionRepository.fetchSearchedMission()
            await send(.set(\.searchedMission, mission))
        } catch {
            // TODO: 에러처리 - 정원
        }
    }

    func searchMission(
        _ attribute: MissionAttribute,
        _ send: Send<Action>
    ) async {
        do {
            let mission = try await missionRepository.searchMission(attribute: attribute)
            await send(.searchResultFetched(mission))
        } catch {
            // TODO: 에러처리 - 정원
        }
    }
}

private extension [Mission] {
    static let mock: [Mission] = [
        .init(
            id: 0,
            title: "음식 관련 미션 예시입니다 1",
            theme: .food,
            isCompleted: false
        ),
        .init(
            id: 1,
            title: "음식 관련 미션 예시입니다 2",
            theme: .food,
            isCompleted: false
        ),
        .init(
            id: 2,
            title: "음식 관련 미션 예시입니다 3",
            theme: .food,
            isCompleted: true
        ),
        .init(
            id: 3,
            title: "음식 관련 미션 예시입니다 4",
            theme: .food,
            isCompleted: false
        ),
        .init(
            id: 4,
            title: "음식 관련 미션 예시입니다 5",
            theme: .food,
            isCompleted: false
        ),
        .init(
            id: 5,
            title: "콘텐츠 관련 미션 예시입니다 1",
            theme: .contents,
            isCompleted: false
        ),
        .init(
            id: 6,
            title: "콘텐츠 관련 미션 예시입니다 2",
            theme: .contents,
            isCompleted: false
        ),
        .init(
            id: 7,
            title: "콘텐츠 관련 미션 예시입니다 3",
            theme: .contents,
            isCompleted: true
        ),
        .init(
            id: 8,
            title: "콘텐츠 관련 미션 예시입니다 4",
            theme: .contents,
            isCompleted: false
        ),
        .init(
            id: 9,
            title: "콘텐츠 관련 미션 예시입니다 5",
            theme: .contents,
            isCompleted: false
        ),
        .init(
            id: 10,
            title: "활동 관련 미션 예시입니다 1",
            theme: .activity,
            isCompleted: false
        ),
        .init(
            id: 11,
            title: "활동 관련 미션 예시입니다 2",
            theme: .activity,
            isCompleted: false
        ),
        .init(
            id: 12,
            title: "활동 관련 미션 예시입니다 3",
            theme: .activity,
            isCompleted: true
        ),
        .init(
            id: 13,
            title: "활동 관련 미션 예시입니다 4",
            theme: .activity,
            isCompleted: false
        ),
        .init(
            id: 14,
            title: "활동 관련 미션 예시입니다 5",
            theme: .activity,
            isCompleted: false
        )
    ]
}
