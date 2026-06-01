//
//  MissionListFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct MissionListFeature {
    @Dependency(\.missionRepository) private var missionRepository
    @Dependency(\.missionSearchGuideClient) private var missionSearchGuideClient

    @ObservableState
    public struct State: Equatable {
        var userType: UserType?
        var solarTerm: SolarTerm?
        var missions: [Mission] = []
        var selectedMission: Mission?
        var searchedMission: Mission?

        @Presents var search: MissionSearchFeature.State?
        @Presents var searchResult: MissionSearchResultFeature.State?

        var isLoading: Bool = false
        var isTooltipPresented: Bool = false
        var isIndicatorEnabled: Bool = false

        public init() {}

        var isSearchMissionButtonEnabled: Bool {
            // TODO: 추후 로직 구현
            true
        }

        var season: Season? {
            solarTerm?.season
        }

        var theme: MissionTheme? {
            selectedMission?.theme
        }

        var selectedIndex: Int? {
            guard let selectedMission else { return nil }
            return missions.firstIndex(of: selectedMission)
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case themeTapped(MissionTheme)
        case indicatorIndexChanged(Int)
        case searchMissionButtonTapped
        case recommendedMissionsFetched(RecommendedMission?)
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
                handleTooltip(&state)
                return .run { [state] send in
                    await fetchAll(state, send)
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
                    guard let season = state.season else { return .none }
                    state.search = .init(season: season)
                }
                return .none
            case let .recommendedMissionsFetched(info):
                guard let info else { return .none }
                let isEqual = state.missions == info.missions
                state.userType = info.userType
                state.solarTerm = info.solarTerm
                state.missions = info.missions

                if isEqual { return .none }
                state.selectedMission = switch info.missions.count {
                case 2...: info.missions[safe: 1]
                default: info.missions[safe: 0]
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
    func handleTooltip(_ state: inout State) {
        if state.isTooltipPresented { return }

        let date = missionSearchGuideClient.lastGuidedDate()
        let calendar = Calendar.current
        if let date, calendar.isDateInToday(date) { return }

        missionSearchGuideClient.setLastGuidedDate(Date.now)
        state.isTooltipPresented = true
    }

    func fetchAll(_ state: State, _ send: Send<Action>) async {
        await send(.set(\.isLoading, true))
        async let recommended = fetchRecommendedMissions(send)
        async let searched = fetchSearchedMission(state, send)
        _ = await (recommended, searched)
        await send(.set(\.isLoading, false))
    }

    func fetchRecommendedMissions(_ send: Send<Action>) async {
        do {
            let info = try await missionRepository.fetchRecommendedMissions()
            await send(.recommendedMissionsFetched(info))
        } catch {
            // TODO: 에러처리 - 정원
        }
    }

    func fetchSearchedMission(_ state: State, _ send: Send<Action>) async {
        do {
            guard state.searchedMission == nil else { return }
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
            let mission = try await missionRepository.searchMission(attribute)
            await send(.searchResultFetched(mission))
        } catch {
            // TODO: 에러처리 - 정원
        }
    }
}
