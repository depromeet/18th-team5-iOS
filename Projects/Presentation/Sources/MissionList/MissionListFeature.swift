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

    public enum Alert: Equatable {
        case missionUnavailable
        case fetchFailed
        case searchFailed
    }

    @ObservableState
    public struct State: Equatable {
        var userType: UserType?
        var solarTerm: SolarTerm?
        var missions: [Mission] = []
        var selectedMission: Mission?
        var searchedMission: Mission?
        var isAvailable: Bool?
        var maxCount: Int?

        @Presents var search: MissionSearchFeature.State?
        @Presents var searchResult: MissionSearchResultFeature.State?

        var isLoading: Bool = false
        var isTooltipPresented: Bool = false
        var isIndicatorEnabled: Bool = false
        var isCompleteViewPresented: Bool = false
        var pendingOpenFromHome: Bool = false

        public init() {}

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
        case missionCardTapped(Mission)
        case recommendedMissionsFetched(RecommendedMission?)
        case searchResultFetched(Mission?)
        case openFromHome
        case resolveFromHomePending
        case showCompleteAnimation
        case binding(BindingAction<State>)
        case search(PresentationAction<MissionSearchFeature.Action>)
        case searchResult(PresentationAction<MissionSearchResultFeature.Action>)
        case delegate(Delegate)
        case dismissAll
    }

    public enum Delegate {
        case navigateToMissionRecord(Mission, MissionType)
        case showAlert(Alert)
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
                    await send(.resolveFromHomePending)
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
            case .openFromHome:
                if let mission = state.searchedMission {
                    state.searchResult = .init(mission)
                } else if let season = state.season {
                    state.search = .init(season: season)
                } else {
                    state.pendingOpenFromHome = true
                }
                return .none
            case .resolveFromHomePending:
                guard state.pendingOpenFromHome else { return .none }
                state.pendingOpenFromHome = false
                if let mission = state.searchedMission {
                    state.searchResult = .init(mission)
                } else if let season = state.season {
                    state.search = .init(season: season)
                }
                return .none
            case .searchMissionButtonTapped:
                if let mission = state.searchedMission {
                    if mission.isCompleted == true {
                        return .send(.delegate(.showAlert(.missionUnavailable)))
                    } else {
                        state.searchResult = .init(mission)
                        return .none
                    }
                } else {
                    guard let season = state.season else { return .none }
                    state.search = .init(season: season)
                    return .none
                }
            case let .missionCardTapped(mission):
                if state.isAvailable == true {
                    return .send(.delegate(.navigateToMissionRecord(mission, .recommended)))
                } else {
                    return .send(.delegate(.showAlert(.missionUnavailable)))
                }
            case let .recommendedMissionsFetched(info):
                guard let info else { return .none }
                let isEqual = state.missions.map(\.id) == info.missions.map(\.id)
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
            case let .searchResult(.presented(.delegate(.navigateToMissionRecord(mission)))):
                state.searchResult = nil
                state.isLoading = true
                return .send(.delegate(.navigateToMissionRecord(mission, .selected)))
            case .showCompleteAnimation:
                return .run { send in
                    try await Task.sleep(for: .seconds(0.3))
                    await send(.set(\.isCompleteViewPresented, true))
                }
            case .dismissAll:
                state.search = nil
                state.searchResult = nil
                return .none
            case .binding: return .none
            case .search: return .none
            case .searchResult: return .none
            case .delegate: return .none
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

        do {
            async let recommended = fetchRecommendedMissions(send)
            async let searched = fetchSearchedMission(state, send)
            async let availability = fetchRecommendedMisisonAvailability(state, send)
            _ = try await (recommended, searched, availability)
            await send(.set(\.isLoading, false))
        } catch {
            await send(.set(\.isLoading, false))
            await send(.delegate(.showAlert(.fetchFailed)))
        }
    }

    func fetchRecommendedMissions(_ send: Send<Action>) async throws {
        let info = try await missionRepository.fetchRecommendedMissions()
        await send(.recommendedMissionsFetched(info))
    }

    func fetchSearchedMission(_ state: State, _ send: Send<Action>) async throws {
        let mission = try await missionRepository.fetchSearchedMission()
        await send(.set(\.searchedMission, mission))
    }

    func searchMission(
        _ attribute: MissionAttribute,
        _ send: Send<Action>
    ) async {
        do {
            let mission = try await missionRepository.searchMission(attribute)
            await send(.searchResultFetched(mission))
        } catch {
            await send(.set(\.isLoading, false))
            await send(.delegate(.showAlert(.searchFailed)))
        }
    }

    func fetchRecommendedMisisonAvailability(
        _ state: State,
        _ send: Send<Action>
    ) async throws {
        let availability = try await missionRepository.fetchRecommendedMissionAvailability()
        await send(.set(\.isAvailable, availability.isAvailable))
        await send(.set(\.maxCount, availability.maxCount))

        if state.isAvailable == true,
           availability.isAvailable == false {
            await send(.showCompleteAnimation)
        }
    }
}
