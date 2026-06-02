//
//  CalendarFeature+Paging.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

// MARK: - 정적 절기 캘린더 페이징

extension CalendarFeature {
    /// #1. 최초 페이지 로딩
    func fetchInitialPages(
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
            await send(.updateCalendarPages(pages))

            if let currentTerm = pages.findAnchorTerm(containing: now) {
                await send(.updateCalendarHeader(mapToHeader(currentTerm)))
                await send(.updateAnchorRequest(
                    AnchorRequest(
                        itemId: currentTerm.id,
                        inset: nil,
                        animated: false
                    )
                ))
            }
        }
    }

    /// #2. 스크롤이 양끝에 도달한 경우 다음 페이지 요청 정보 도출
    func calendarPagingRequest(
        _ state: inout State,
        direction: PageEndDirection
    ) -> Effect<Action> {
        guard !state.isPaging,
              let anchoredTermId = state.anchoredTermId,
              let termGroup = findTermGroup(
                  pages: state.calendarState.pages,
                  termId: anchoredTermId
              )
        else { return .none }

        let centerYear = termGroup.solarTermInfo.year
        guard let fetchingYear = direction == .top
            ? centerYear.prevYear
            : centerYear.nextYear
        else { return .none }

        state.isPaging = true
        let currentPages = state.calendarState.pages
        let now = date.now

        return fetchPagingYear(
            direction: direction,
            fetchingYear: fetchingYear,
            currentPages: currentPages,
            now: now
        )
    }

    /// #3. 해당 연도의 절기 정보 요청
    func fetchPagingYear(
        direction: PageEndDirection,
        fetchingYear: SolarTermYear,
        currentPages: [Page<SolarTermGroup>],
        now: Date
    ) -> Effect<Action> {
        .run { send in
            do {
                let fetchedTerms = try await solarTermRepository.fetchSolarTerms(fetchingYear)
                let newPage = mapToYearGroup(now: now, year: fetchingYear, terms: fetchedTerms)
                let updated = applyPaging(direction: direction, newPage: newPage, to: currentPages)
                await send(.updateCalendarPages(updated))
            } catch {
                try? await Task.sleep(for: .seconds(1))
            }
            await send(.yearPagesLayoutCompleted)
        }
    }

    func applyPaging(
        direction: PageEndDirection,
        newPage: Page<SolarTermGroup>,
        to pages: [Page<SolarTermGroup>]
    ) -> [Page<SolarTermGroup>] {
        var updated: [Page<SolarTermGroup>]
        switch direction {
        case .top:
            updated = [newPage] + pages
            if updated.count > 3 { updated.removeLast() }
        case .bottom:
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
