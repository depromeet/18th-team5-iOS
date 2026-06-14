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
        var hasError: Bool = false

        public init() {}
    }

    public enum Action {
        case onAppear
        case onRetryTap
        case homeLoad(Result<HomeCard, Error>)
        case seasonRecordLoad(Result<SeasonRecord, Error>)
        case onMissionTap
        case onMissionRecommendTap
        case onSolarTermDetailTap
        case myPageButtonTapped
        case calendarButtonTapped
        case onRecordPhotoTap(String)
        case delegate(Delegate)

        public enum Delegate {
            case navigateToMissionCamera(missionId: Int, title: String, missionType: String)
            case navigateToMissionTab
            case navigateToSolarTermContent(SolarTerm)
            case navigateToCalendar
            case navigateToCalendarRecord(Date)
            case navigateToMyPage
        }
    }

    @Dependency(\.homeRepository) var homeRepository
    @Dependency(\.missionRepository) var missionRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .onRetryTap:
                state.hasError = false
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
                state.hasError = true
                print("HomeFeature fetchHome 실패: \(error)")
                return .none

            case let .seasonRecordLoad(.success(record)):
                state.seasonRecord = record
                ImagePrefetchService.prefetch(record.photoURL)
                return .none

            case let .seasonRecordLoad(.failure(error)):
                print("HomeFeature fetchSeasonalRecords 실패: \(error)")
                return .none

            case .onMissionTap:
                guard let homeCard = state.homeCard,
                      let mission = homeCard.currentMission else { return .none }
                return .send(.delegate(.navigateToMissionCamera(
                    missionId: mission.id,
                    title: mission.title,
                    missionType: mission.missionType
                )))

            case .onMissionRecommendTap:
                return .send(.delegate(.navigateToMissionTab))

            case .onSolarTermDetailTap:
                guard let term = state.homeCard?.solarTerm.term else { return .none }
                return .send(.delegate(.navigateToSolarTermContent(term)))

            case .myPageButtonTapped:
                return .send(.delegate(.navigateToMyPage))

            case .calendarButtonTapped:
                return .send(.delegate(.navigateToCalendar))

            case let .onRecordPhotoTap(dateString):
                guard let date = DateFormatter.yearMonthDayDash.date(from: dateString)
                else { return .none }
                return .send(.delegate(.navigateToCalendarRecord(date)))

            case .delegate:
                return .none
            }
        }
    }
}
