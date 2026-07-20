//
//  MissionListFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Core
import Domain
import Foundation

@Reducer
public struct MissionListFeature {
    @Dependency(\.missionRepository) private var missionRepository
    @Dependency(\.missionSearchGuideClient) private var missionSearchGuideClient
    @Dependency(\.analyticsClient) private var analyticsClient

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
        case missionCardScrolled(Mission)
        case searchMissionButtonTapped
        case missionCardTapped(Mission)
        case recommendedMissionsFetched(RecommendedMission?)
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
                analyticsClient.logMissionScreenView()
                handleTooltip(&state)
                return .run { [state] send in
                    await fetchAll(state, send)
                    await send(.resolveFromHomePending)
                }
            case let .themeTapped(theme):
                analyticsClient.logMissionCategoryTap(theme)
                let fromIndex = state.missions.firstIndex { $0 == state.selectedMission }
                let toIndex = state.missions.firstIndex { $0.theme == theme }
                let mission = state.missions[safe: toIndex]

                guard let mission else { return .none }
                state.selectedMission = mission

                logMissionCardNavigation(method: .tab, fromIndex: fromIndex, toIndex: toIndex)
                return .none
            case let .missionCardScrolled(mission):
                let fromIndex = state.missions.firstIndex { $0 == state.selectedMission }
                let toIndex = state.missions.firstIndex { $0 == mission }
                state.selectedMission = mission

                logMissionCardNavigation(method: .scroll, fromIndex: fromIndex, toIndex: toIndex)
                return .none
            case let .indicatorIndexChanged(toIndex):
                let fromIndex = state.missions.firstIndex { $0 == state.selectedMission }
                guard state.missions.indices.contains(toIndex) else { return .none }
                state.selectedMission = state.missions[toIndex]

                logMissionCardNavigation(method: .indicator, fromIndex: fromIndex, toIndex: toIndex)
                return .none
            case .openFromHome:
                if let mission = state.searchedMission {
                    guard let solarTerm = state.solarTerm else { return .none }
                    state.searchResult = .init(solarTerm, mission)
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
                    if let solarTerm = state.solarTerm {
                        state.searchResult = .init(solarTerm, mission)
                    }
                } else if let season = state.season {
                    state.search = .init(season: season)
                }
                return .none
            case .searchMissionButtonTapped:
                analyticsClient.logSelectMissionTap()
                if let mission = state.searchedMission {
                    if mission.isCompleted == true {
                        return .send(.delegate(.showAlert(.missionUnavailable)))
                    } else {
                        guard let solarTerm = state.solarTerm else { return .none }
                        state.searchResult = .init(solarTerm, mission)
                        return .none
                    }
                } else {
                    guard let season = state.season else { return .none }
                    state.search = .init(season: season)
                    return .none
                }
            case let .missionCardTapped(mission):
                let index = state.missions.firstIndex(of: mission)
                analyticsClient.logMissionCardTap(mission, index)
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
            case let .search(.presented(.delegate(.searchMission(attribute)))):
                state.search = nil
                guard let solarTerm = state.solarTerm else { return .none }
                state.searchResult = .init(solarTerm)
                state.searchResult?.attribute = attribute
                return .none
            case let .searchResult(.presented(.searchResultFetched(mission))):
                state.searchedMission = mission
                return .none
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

    func logMissionCardNavigation(
        method: MissionCardNavigationMethod,
        fromIndex: Int?,
        toIndex: Int?
    ) {
        guard let fromIndex, let toIndex, fromIndex != toIndex else { return }

        let navigation = MissionCardNavigation(
            method: method,
            fromPosition: fromIndex,
            toPosition: toIndex
        )

        analyticsClient.logMissionCardNavigate(navigation)
    }
}
