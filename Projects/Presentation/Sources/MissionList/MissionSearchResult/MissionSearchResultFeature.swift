//
//  MissionSearchResultFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct MissionSearchResultFeature {
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.missionRepository) private var missionRepository

    @ObservableState
    public struct State: Equatable {
        // TODO: MOCK 데이터 - 추후에 수정 예정
        let solarTerm: SolarTerm
        var mission: Mission?
        var attribute: MissionAttribute?

        public init(
            _ solarTerm: SolarTerm,
            _ mission: Mission? = nil
        ) {
            self.solarTerm = solarTerm
            self.mission = mission
        }

        var isSearching: Bool {
            mission == nil
        }

        var season: Season {
            solarTerm.season
        }

        var locationType: LocationType? {
            mission?.attribute?.locationType
        }

        var participationType: ParticipationType? {
            mission?.attribute?.participationType
        }

        var category: MissionCategory? {
            mission?.attribute?.category
        }
    }

    public enum Action {
        case onAppear
        case searchResultFetched(Mission?)
        case backButtonTapped
        case bottomButtonTapped
        case delegate(Delegate)
    }

    public enum Delegate {
        case navigateToMissionRecord(Mission)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let attribute = state.attribute
                guard let attribute else { return .none }
                return .run { send in
                    await searchMission(attribute, send)
                }
            case let .searchResultFetched(mission):
                state.mission = mission
                return .none
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            case .bottomButtonTapped:
                guard let mission = state.mission else { return .none }
                return .send(.delegate(.navigateToMissionRecord(mission)))
            case .delegate: return .none
            }
        }
    }
}

private extension MissionSearchResultFeature {
    func searchMission(
        _ attribute: MissionAttribute,
        _ send: Send<Action>
    ) async {
        do {
            let mission = try await missionRepository.searchMission(attribute)
            await send(.searchResultFetched(mission))
        } catch {
            // TODO: 조회 실패
        }
    }
}
