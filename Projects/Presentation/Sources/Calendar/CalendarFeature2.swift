//
//  CalendarFeature2.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CalendarFeature2 {
    @ObservableState
    public struct State: Equatable {
        public var header: CalendarHeaderModel = .init(
            termTitleText: "테스트", termRangeText: "11.11~11.11"
        )

        public var solarTermGroups: [SolarTermGroup] = []
        public var anchor: CalendarAnchor?

        fileprivate var currentYear: SolarTermYear = .y2026
        fileprivate var solarTerms: [SolarTermYear: [SolarTermInfo]] = [:]
    }

    public enum Action {
        case onAppear
        case updateSolarTermGroups([SolarTermGroup])
        case fetchSolarTerms(SolarTermYear)
        case solarTermsFetched(SolarTermYear, [SolarTermInfo])
    }

    @Dependency(\.logger) var logger
    @Dependency(\.date) var date
    @Dependency(\.solarTermRepository) var solarTermRepository

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let now = date.now

                guard let year = Calendar.current.dateComponents([.year], from: now).year,
                      let solarYear = SolarTermYear(rawValue: year)
                else {
                    assertionFailure("해당하는 연도 정보를 획득할 수 없습니다.")
                    return .none
                }

                state.currentYear = solarYear
                return fetchTerms(for: solarYear)

            case let .fetchSolarTerms(year):
                guard state.solarTerms[year] == nil else { return .none }
                return fetchTerms(for: year)

            case let .solarTermsFetched(year, terms):
                state.solarTerms[year] = terms

                if year == state.currentYear {
                    let now = date.now
                    let term = terms.first { $0.dateRange.contains(now) }!.term
                    let anchor = CalendarAnchor(year: year, term: term)
                    return updateDisplays(base: anchor, state: state)
                }

                return .none

            case let .updateSolarTermGroups(groups):
                state.solarTermGroups = groups
                return .none
            }
        }
    }
}

private extension CalendarFeature2 {
    func fetchTerms(for year: SolarTermYear) -> Effect<Action> {
        return .run { send in
            let terms = try await solarTermRepository.fetchSolarTerms(year)
            await send(.solarTermsFetched(year, terms))
        }
    }

    func updateDisplays(base: CalendarAnchor, state: State) -> Effect<Action> {
        guard let terms = state.solarTerms[base.year],
              let currentTermIndex = terms.firstIndex(where: { $0.term == base.term })
        else { return .none }

        let windowSize = 3

        var groups: [SolarTermGroup] = []

        // MARK: #1. Prev year

        if currentTermIndex - windowSize < 0 {
            // 이전 연도 데이터가 필요한 경우
            guard let prevYear = base.year.prevYear else {
                logger.debug(message: "더 이전 연도가 존재하지 않습니다.")
                return .none
            }

            guard let prevYearTerms = state.solarTerms[prevYear] else {
                return fetchTerms(for: prevYear)
            }

            let prevCount = abs(currentTermIndex - windowSize)
            for term in prevYearTerms.suffix(prevCount) {
                groups.append(cteateGroup(term))
            }
        }

        // MARK: #2. Current year

        let displayRange = max(0, currentTermIndex - windowSize) ... min(terms.count - 1, currentTermIndex + windowSize)
        for index in displayRange {
            groups.append(cteateGroup(terms[index]))
        }

        // MARK: #3. Next year

        if currentTermIndex + windowSize > terms.count {
            // 다음 연도 데이터가 필요한 경우
            guard let nextYear = base.year.nextYear else {
                logger.debug(message: "다음 연도가 존재하지 않습니다.")
                return .none
            }

            guard let nextYearTerms = state.solarTerms[nextYear] else {
                return fetchTerms(for: nextYear)
            }

            let nextCount = currentTermIndex + windowSize - (terms.count - 1)
            for term in nextYearTerms.prefix(nextCount) {
                groups.append(cteateGroup(term))
            }
        }

        return .send(.updateSolarTermGroups(groups))
    }

    func cteateGroup(_ term: SolarTermInfo) -> SolarTermGroup {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let weekday = calendar.component(.weekday, from: term.startDate)
        let offset = (weekday - 2 + 7) % 7

        var cells: [SolarTermGroupCell] = []

        for index in 0 ..< offset {
            cells.append(.emptyCell(
                id: "\(term.year.rawValue)_\(term.term.rawValue)_emptycell\(index)"
            ))
        }

        for date in term.termDates {
            cells.append(.dateCell(
                SolarTermDate(
                    id: date.description,
                    dayText: Self.dayFormatter.string(from: date),
                    isToday: false
                )
            )
            )
        }
        return SolarTermGroup(
            id: "\(term.year.rawValue)_\(term.term.rawValue)",
            cells: cells
        )
    }

    static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df
    }()
}

private extension SolarTermInfo {
    var termDates: [Date] {
        let start = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)

        var dates: [Date] = [start]
        var next = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        while next < end {
            dates.append(next)
            next = Calendar.current.date(byAdding: .day, value: 1, to: next)!
        }
        return dates
    }
}
