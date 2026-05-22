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
        public var header: CalendarHeader?
        public var yearPages: [Page<SolarTermGroup>] = []
        public var anchoredTermId: SolarTermGroup.ID?
        public var isPaging: Bool = false
        public var anchorRequest: AnchorRequest<SolarTermGroup>?
        public var selectedDateId: SolarTermDate.ID?

        fileprivate var currentYear: SolarTermYear = .y2026
    }

    public enum Action: BindableAction {
        case onAppear
        case updateCalendarHeader(CalendarHeader)
        case updateAnchorRequest(AnchorRequest<SolarTermGroup>)
        case calendarPagingRequest(PagingDirection)
        case dateCellTapped(dateId: SolarTermDate.ID, inset: CGFloat)
        case updateYearPages([Page<SolarTermGroup>])
        case yearPagesLayoutCompleted
        case binding(BindingAction<State>)
    }

    @Dependency(\.logger) var logger
    @Dependency(\.date) var date
    @Dependency(\.solarTermRepository) var solarTermRepository

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return onAppear(&state)

            case let .updateCalendarHeader(header):
                state.header = header
                return .none

            case let .updateAnchorRequest(request):
                state.anchorRequest = request
                return .none

            case let .updateYearPages(pages):
                state.yearPages = pages
                return .none

            case .yearPagesLayoutCompleted:
                state.isPaging = false
                return .none

            case let .calendarPagingRequest(direction):
                return calendarPagingRequest(&state, direction: direction)

            case let .dateCellTapped(dateId, inset):
                return dateCellTapped(&state, dateId: dateId, inset: inset)

            case .binding(\.anchoredTermId):
                if let termId = state.anchoredTermId,
                   let currentTerm = findTermGroup(
                       pages: state.yearPages, termId: termId
                   ) {
                    return .send(.updateCalendarHeader(mapToHeader(currentTerm)))
                }
                return .none

            default:
                return .none
            }
        }
    }
}

// MARK: - Effect 분리

extension CalendarFeature2 {
    private func onAppear(_ state: inout State) -> Effect<Action> {
        let now = date.now
        guard let year = Calendar.current.dateComponents([.year], from: now).year,
              let currentYear = SolarTermYear(rawValue: year)
        else {
            assertionFailure("해당하는 연도 정보를 획득할 수 없습니다.")
            return .none
        }
        state.currentYear = currentYear
        return fetchInitialPages(currentYear: currentYear, now: now)
    }

    private func fetchInitialPages(
        currentYear: SolarTermYear,
        now: Date
    ) -> Effect<Action> {
        .run { send in
            let years = [
                currentYear.prevYear,
                currentYear,
                currentYear.nextYear
            ].compactMap(\.self)

            let pages = await fetchYearPages(years: years, now: now)
            await send(.updateYearPages(pages))

            if let anchoredPage = pages.findAnchorTerm(containing: now) {
                await send(.updateAnchorRequest(
                    AnchorRequest(
                        itemId: anchoredPage.id,
                        inset: nil,
                        animated: false
                    )
                ))
            }
        }
    }

    private func calendarPagingRequest(
        _ state: inout State,
        direction: PagingDirection
    ) -> Effect<Action> {
        guard !state.isPaging,
              let anchoredTermId = state.anchoredTermId,
              let termGroup = findTermGroup(
                  pages: state.yearPages,
                  termId: anchoredTermId
              )
        else { return .none }

        let centerYear = termGroup.solarTermInfo.year
        guard let fetchingYear = direction == .prepend
            ? centerYear.prevYear
            : centerYear.nextYear
        else { return .none }

        state.isPaging = true
        let currentPages = state.yearPages
        let now = date.now

        return fetchPagingYear(
            direction: direction,
            fetchingYear: fetchingYear,
            currentPages: currentPages,
            now: now
        )
    }

    private func dateCellTapped(
        _ state: inout State,
        dateId: SolarTermDate.ID,
        inset: CGFloat
    ) -> Effect<Action> {
        state.selectedDateId = dateId
        for pageIndex in state.yearPages.indices {
            for termIndex in state.yearPages[pageIndex].items.indices {
                let term = state.yearPages[pageIndex].items[termIndex]
                for cell in term.cells.flatMap(\.self) {
                    if case let .dateCell(date) = cell, date.id == dateId {
                        let request = AnchorRequest<SolarTermGroup>(
                            itemId: term.id,
                            inset: inset,
                            animated: true
                        )
                        state.anchoredTermId = term.id
                        return .send(.updateAnchorRequest(request))
                    }
                }
            }
        }
        return .none
    }

    private func fetchPagingYear(
        direction: PagingDirection,
        fetchingYear: SolarTermYear,
        currentPages: [Page<SolarTermGroup>],
        now: Date
    ) -> Effect<Action> {
        .run { send in
            do {
                let fetchedTerms = try await solarTermRepository.fetchSolarTerms(fetchingYear)
                let newPage = mapToYearGroup(now: now, year: fetchingYear, terms: fetchedTerms)
                let updated = applyPaging(direction: direction, newPage: newPage, to: currentPages)
                await send(.updateYearPages(updated))
            } catch {
                try? await Task.sleep(for: .seconds(1))
            }
            await send(.yearPagesLayoutCompleted)
        }
    }
}

// MARK: - 페이지 유틸리티

extension CalendarFeature2 {
    func findTermGroup(pages: [Page<SolarTermGroup>], termId: SolarTermGroup.ID) -> SolarTermGroup? {
        for yearPage in pages {
            for termGroup in yearPage.items {
                if termGroup.id == termId { return termGroup }
            }
        }
        return nil
    }

    func applyPaging(
        direction: PagingDirection,
        newPage: Page<SolarTermGroup>,
        to pages: [Page<SolarTermGroup>]
    ) -> [Page<SolarTermGroup>] {
        var updated: [Page<SolarTermGroup>]
        switch direction {
        case .prepend:
            updated = [newPage] + pages
            if updated.count > 3 { updated.removeLast() }
        case .append:
            updated = pages + [newPage]
            if updated.count > 3 { updated.removeFirst() }
        }
        return updated
    }

    func fetchYearPages(
        years: [SolarTermYear],
        now: Date
    ) async -> [Page<SolarTermGroup>] {
        await withTaskGroup(
            of: (SolarTermYear, Page<SolarTermGroup>)?.self,
            returning: [Page<SolarTermGroup>].self
        ) { group in
            for year in years {
                group.addTask { [solarTermRepository] in
                    guard let terms = try? await solarTermRepository.fetchSolarTerms(year)
                    else { return nil }
                    return (year, mapToYearGroup(now: now, year: year, terms: terms))
                }
            }
            var results: [(SolarTermYear, Page<SolarTermGroup>)] = []
            for await value in group {
                guard let value else { continue }
                results.append(value)
            }
            return results
                .sorted(by: { $0.0.rawValue < $1.0.rawValue })
                .map(\.1)
        }
    }
}

// MARK: - 매핑 유틸리티

extension CalendarFeature2 {
    func mapToHeader(_ term: SolarTermGroup) -> CalendarHeader {
        let info = term.solarTermInfo
        let startText = Self.termDateFormatter.string(from: info.startDate)
        let endText = Self.termDateFormatter.string(from: info.endDate)
        return CalendarHeader(
            termTitleText: term.termText,
            termRangeText: "\(startText)~\(endText)"
        )
    }

    func mapToYearGroup(now: Date, year: SolarTermYear, terms: [SolarTermInfo]) -> Page<SolarTermGroup> {
        Page(
            id: year.rawValue,
            items: terms.map { mapToTermGroup(now, $0) }
        )
    }

    func mapToTermGroup(_ now: Date, _ termInfo: SolarTermInfo) -> SolarTermGroup {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let weekday = calendar.component(.weekday, from: termInfo.startDate)
        let offset = (weekday - 2 + 7) % 7

        var cells: [SolarTermGroupCell] = []
        for index in 0 ..< offset {
            cells.append(.emptyCell(
                id: "\(termInfo.year.rawValue)_\(termInfo.term.rawValue)_emptycell_\(index)"
            ))
        }
        for date in termInfo.termDates {
            guard let ymd = yearMonthDay(date),
                  let todayYmd = yearMonthDay(now)
            else { continue }
            cells.append(
                .dateCell(
                    SolarTermDate(
                        id: date.description,
                        monthText: "\(ymd.month)월",
                        dayText: String(ymd.day),
                        isFirstDayOfMonth: ymd.day == 1,
                        isToday: ymd == todayYmd
                    )
                )
            )
        }
        return SolarTermGroup(
            id: termInfo.identifier,
            termText: termInfo.term.koreanName,
            solarTermInfo: termInfo,
            cells: cells.chunked(size: 7)
        )
    }

    func yearMonthDay(_ date: Date) -> (year: Int, month: Int, day: Int)? {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day
        else { return nil }
        return (year, month, day)
    }

    static let termDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM.dd"
        return df
    }()

    static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df
    }()
}

// MARK: - Anchor 탐색

private extension [Page<SolarTermGroup>] {
    func findAnchorTerm(containing date: Date) -> SolarTermGroup? {
        for page in self {
            for term in page.items {
                if term.solarTermInfo.dateRange.contains(date) {
                    return term
                }
            }
        }
        return nil
    }
}

// MARK: - SolarTermInfo 확장

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

    var identifier: String {
        "\(year.rawValue)-\(term.rawValue)"
    }
}

private extension Array {
    func chunked(size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
