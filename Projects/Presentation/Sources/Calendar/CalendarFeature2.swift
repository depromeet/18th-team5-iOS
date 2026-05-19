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

        public var yearPages: [Page<SolarTermGroup>] = []
        public var centerItemId: SolarTermGroup.ID?

        fileprivate var currentYear: SolarTermYear = .y2026
    }

    public enum Action: BindableAction {
        case onAppear
        case centerTermChanged(SolarTermGroup.ID)
        case calendarPagingRequest(PagingDirection)
        case updateYearPages([Page<SolarTermGroup>])
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
                                guard let terms = try? await solarTermRepository.fetchSolarTerms(year: year)
                                else { return nil }
                                return (year, mapToYearGroup(year: year, terms: terms))
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
                                await send(.centerTermChanged(term.id))
                                break
                            }
                        }
                    }
                }

            case let .centerTermChanged(termId):
                state.centerItemId = termId
                return .none

            case let .updateYearPages(pages):
                state.yearPages = pages
                return .none

            case let .calendarPagingRequest(direction):
                guard let centerId = state.centerItemId,
                      let termGroup = findTermGroup(pages: state.yearPages, termId: centerId)
                else { return .none }

                let termInfo = termGroup.solarTermInfo
                let centerYear = termInfo.year
                let fetchingYear = switch direction {
                case .prepend: centerYear.prevYear
                case .append: centerYear.nextYear
                }

                guard let fetchingYear else { return .none }

                let currentPages = state.yearPages

                return .run { send in
                    let fetchedTerms = try await solarTermRepository.fetchSolarTerms(year: fetchingYear)
                    let newYearGroup = mapToYearGroup(year: fetchingYear, terms: fetchedTerms)
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
                }

            case .binding: return .none
            }
        }
    }
}

private extension CalendarFeature2 {
    func findTermGroup(pages: [Page<SolarTermGroup>], termId: SolarTermGroup.ID) -> SolarTermGroup? {
        for yearPage in pages {
            for termGroup in yearPage.items {
                if termGroup.id == termId {
                    return termGroup
                }
            }
        }
        return nil
    }

    func mapToYearGroup(year: SolarTermYear, terms: [SolarTermInfo]) -> Page<SolarTermGroup> {
        Page(
            id: year.rawValue,
            items: terms.map { mapToTermGroup($0) }
        )
    }

    func mapToTermGroup(_ term: SolarTermInfo) -> SolarTermGroup {
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
            cells.append(
                .dateCell(
                    SolarTermDate(
                        id: date.description,
                        dayText: Self.dayFormatter.string(from: date),
                        isToday: false
                    )
                )
            )
        }
        return SolarTermGroup(
            id: term.identifier,
            solarTermInfo: term,
            cells: cells.chunked(size: 7)
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
