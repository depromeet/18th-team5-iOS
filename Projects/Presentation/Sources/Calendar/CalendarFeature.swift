//  CalendarFeature.swift
//  Presentation
//
//  Created by 송민교 on 5/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CalendarFeature {
    @ObservableState
    public struct State: Equatable {
        var currentMonth: Date = .now
        var dailyRecords: [DateComponents: CalendarRecord] = [:]
        var selectedDate: Date?
        var isLoading: Bool = false
        @Presents var dayDetail: DayDetailFeature.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case previousMonthTap
        case nextMonthTap
        case dayTap(Date)
        case recordsLoad(Result<[CalendarRecord], Error>)
        case dayDetail(PresentationAction<DayDetailFeature.Action>)
    }

    @Dependency(\.calendarRepository) var calendarRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return fetchRecords(for: state.currentMonth)

            case .previousMonthTap:
                state.isLoading = true
                state.selectedDate = nil
                state.currentMonth = Calendar.current.date(
                    byAdding: .month, value: -1, to: state.currentMonth
                ) ?? state.currentMonth
                return fetchRecords(for: state.currentMonth)

            case .nextMonthTap:
                state.isLoading = true
                state.selectedDate = nil
                state.currentMonth = Calendar.current.date(
                    byAdding: .month, value: 1, to: state.currentMonth
                ) ?? state.currentMonth
                return fetchRecords(for: state.currentMonth)

            case let .dayTap(date):
                let key = dateKey(from: date)
                guard state.dailyRecords[key] != nil else { return .none }

                state.selectedDate = date
                // TODO: 월 경계 주간에서 인접 월 기록 누락 가능(API 연동 시 인접 월 데이터도 함께 주입하거나 주 단위 별도 로드로 대응 필요) - @minkyo
                state.dayDetail = DayDetailFeature.State(
                    selectedDate: date,
                    weekRecords: state.dailyRecords
                )
                return .none

            case let .recordsLoad(.success(records)):
                state.isLoading = false

                var dict: [DateComponents: CalendarRecord] = [:]
                for record in records {
                    dict[dateKey(from: record.date)] = record
                }
                state.dailyRecords = dict
                return .none

            case .recordsLoad(.failure):
                state.isLoading = false
                return .none

            case .dayDetail(.dismiss):
                // 유저가 sheet를 스와이프로 닫으면 날짜 초기화
                state.selectedDate = nil
                return .none

            case .dayDetail:
                return .none
            }
        }
        .ifLet(\.$dayDetail, action: \.dayDetail) {
            DayDetailFeature()
        }
    }

    private func fetchRecords(for month: Date) -> Effect<Action> {
        let components = Calendar.current.dateComponents([.year, .month], from: month)
        guard let yearValue = components.year, let monthValue = components.month else { return .none }
        return .run { send in
            await send(.recordsLoad(
                Result { try await calendarRepository.fetchMonthRecords(yearValue, monthValue) }
            ))
        }
    }

    private func dateKey(from date: Date) -> DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: date)
    }
}
