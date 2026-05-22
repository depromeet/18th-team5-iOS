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

        fileprivate var currentYear: SolarTermYear = .y2026
    }

    public enum Action: BindableAction {
        case onAppear
        case updateCalendarHeader(CalendarHeader)
        case updateAnchorRequest(AnchorRequest<SolarTermGroup>)
        case calendarPagingRequest(PagingDirection)
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
                let now = date.now
                guard let year = Calendar.current.dateComponents([.year], from: now).year,
                      let currentYear = SolarTermYear(rawValue: year)
                else {
                    assertionFailure("해당하는 연도 정보를 획득할 수 없습니다.")
                    return .none
                }

                return .run { send in
                    let years = [
                        currentYear.prevYear,
                        currentYear,
                        currentYear.nextYear
                    ].compactMap(\.self)

                    let pages = await withTaskGroup(
                        of: (SolarTermYear, Page<SolarTermGroup>)?.self,
                        returning: [Page<SolarTermGroup>].self
                    ) { group in

                        for year in years {
                            group.addTask {
                                guard let terms = try? await solarTermRepository.fetchSolarTerms(year)
                                else { return nil }
                                return (year, mapToYearGroup(
                                    now: now,
                                    year: year,
                                    terms: terms
                                ))
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

                    await send(.updateYearPages(pages))

                    for page in pages {
                        for term in page.items {
                            if term.solarTermInfo.dateRange.contains(now) {
                                let request = AnchorRequest<SolarTermGroup>(
                                    itemId: term.id,
                                    animated: false
                                )
                                await send(.updateAnchorRequest(request))
                                break
                            }
                        }
                    }
                }

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
                guard !state.isPaging,
                      let anchoredTermId = state.anchoredTermId,
                      let termGroup = findTermGroup(
                          pages: state.yearPages,
                          termId: anchoredTermId
                      )
                else { return .none }

                let termInfo = termGroup.solarTermInfo
                let centerYear = termInfo.year
                let fetchingYear = switch direction {
                case .prepend: centerYear.prevYear
                case .append: centerYear.nextYear
                }

                guard let fetchingYear else { return .none }

                state.isPaging = true
                let currentPages = state.yearPages
                let now = date.now

                return .run { send in
                    do {
                        let fetchedTerms = try await solarTermRepository.fetchSolarTerms(fetchingYear)
                        let newYearGroup = mapToYearGroup(
                            now: now,
                            year: fetchingYear,
                            terms: fetchedTerms
                        )
                        switch direction {
                        case .prepend:
                            var updated = [newYearGroup] + currentPages
                            if updated.count > 3 {
                                updated.removeLast()
                            }
                            await send(.updateYearPages(updated))
                        case .append:
                            var updated = currentPages + [newYearGroup]
                            if updated.count > 3 {
                                updated.removeFirst()
                            }
                            await send(.updateYearPages(updated))
                        }
                        await send(.yearPagesLayoutCompleted)
                    } catch {
                        try? await Task.sleep(for: .seconds(1))
                        await send(.yearPagesLayoutCompleted)
                    }
                }

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

private extension CalendarFeature2 {
    func findTermGroup(pages: [Page<SolarTermGroup>], termId: SolarTermGroup.ID) -> SolarTermGroup? {
        for yearPage in pages {
            for termGroup in yearPage.items {
                if termGroup.id == termId { return termGroup }
            }
        }
        return nil
    }

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
            let year = termInfo.year.rawValue
            let term = termInfo.term.rawValue
            cells.append(.emptyCell(
                id: "\(year)_\(term)_emptycell_\(index)"
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
