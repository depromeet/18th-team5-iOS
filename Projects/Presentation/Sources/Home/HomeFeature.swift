//
//  HomeFeature.swift
//  Presentation
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Core
import DesignSystem
import Domain
import Foundation

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        var homeCard: HomeCard?
        var seasonRecord: SeasonRecord?
        var isLoading: Bool = false
        var alert: CustomAlertFeature<Alert>.State?

        public init() {}
    }

    public enum Alert: Equatable {
        case loadFailed
    }

    public enum Action {
        case onAppear
        case homeLoad(Result<HomeCard, Error>)
        case alert(CustomAlertFeature<Alert>.Action)
        case seasonRecordLoad(Result<SeasonRecord, Error>)
        case onMissionTap
        case onMissionRecommendTap
        case onSolarTermDetailTap
        case myPageButtonTapped
        case calendarButtonTapped
        case onRecordPhotoTap(String)
        case delegate(Delegate)

        public enum Delegate {
            case navigateToMissionCamera(missionId: Int, title: String, description: String, missionType: String)
            case navigateToMissionTab
            case navigateToSolarTermContent(SolarTerm)
            case navigateToCalendar
            case navigateToCalendarRecord(Date)
            case navigateToMyPage
        }
    }

    @Dependency(\.homeRepository) private var homeRepository
    @Dependency(\.missionRepository) private var missionRepository
    @Dependency(\.analyticsClient) private var analyticsClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                analyticsClient.logHomeScreenView()
                state.isLoading = true
                return .run { send in
                    do {
                        let data = try await homeRepository.fetchCard()
                        await send(.homeLoad(.success(data)))
                    } catch {
                        await send(.homeLoad(.failure(error)))
                    }
                }

            case let .homeLoad(.success(data)):
                state.isLoading = false
                state.homeCard = data
                return .run { send in
                    do {
                        var record = try await homeRepository.fetchSeasonalRecords()
                        record.solarTermName = data.solarTerm.name
                        await send(.seasonRecordLoad(.success(record)))
                    } catch {
                        await send(.seasonRecordLoad(.failure(error)))
                    }
                }

            case let .homeLoad(.failure(error)):
                state.isLoading = false
                state.alert = CustomAlertFeature<Alert>.State(.loadFailed)
                print("HomeFeature fetchHome 실패: \(error)")
                return .none

            case .alert(.primaryButtonTapped):
                state.alert = nil
                return .send(.onAppear)

            case .alert:
                return .none

            case let .seasonRecordLoad(.success(record)):
                state.seasonRecord = record
                ImagePrefetchService.prefetch(record.photoURL)
                return .none

            case let .seasonRecordLoad(.failure(error)):
                print("HomeFeature fetchSeasonalRecords 실패: \(error)")
                return .none

            case .onMissionTap:
                guard let homeCard = state.homeCard else { return .none }
                guard let mission = homeCard.currentMission else {
                    return .send(.delegate(.navigateToMissionTab))
                }

                analyticsClient.logHomeQuickRecordTap(mission.id)
                return .send(.delegate(.navigateToMissionCamera(
                    missionId: mission.id,
                    title: mission.title,
                    description: mission.description,
                    missionType: mission.missionType
                )))

            case .onMissionRecommendTap:
                analyticsClient.logHomeMissionShortcutTap()
                return .send(.delegate(.navigateToMissionTab))

            case .onSolarTermDetailTap:
                guard let term = state.homeCard?.solarTerm.term else { return .none }
                return .send(.delegate(.navigateToSolarTermContent(term)))

            case .myPageButtonTapped:
                return .send(.delegate(.navigateToMyPage))

            case .calendarButtonTapped:
                let recordCount = state.seasonRecord?.recordCount
                analyticsClient.logHomeRecordMoreTap(recordCount)
                return .send(.delegate(.navigateToCalendar))

            case let .onRecordPhotoTap(dateString):
                guard let date = DateFormatter.serverTimestamp.date(from: dateString)
                else { return .none }

                return .send(.delegate(.navigateToCalendarRecord(date)))

            case .delegate:
                return .none
            }
        }
    }
}

extension HomeFeature.Alert: AlertPresentable {
    public var alertInfo: AlertInfo {
        switch self {
        case .loadFailed:
            return AlertInfo(
                title: "데이터를 불러오지 못했어요",
                buttonTitle: "다시 시도"
            )
        }
    }
}
