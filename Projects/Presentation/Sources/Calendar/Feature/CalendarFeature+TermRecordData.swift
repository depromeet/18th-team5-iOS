//
//  CalendarFeature+TermRecordData.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

// MARK: - Term data, 캘린더 기록 정보

public enum TermFetchRequest: Hashable, Sendable {
    case today
    case specific(id: Int)
}

extension CalendarFeature {
    func fetchCalendarData(
        _ state: State,
        _ request: TermFetchRequest
    ) -> Effect<Action> {
        .run { send in
            do {
                let res = switch request {
                case .today:
                    try await calendarRecordRepository.fetchCurrentSolarTerms()
                case let .specific(id):
                    try await calendarRecordRepository.fetchSolarTerms(id)
                }

                for item in res.fetchedTermRecords {
                    await send(.updateTermRecordData(
                        id: Self.termRecordKey(item.year, item.term),
                        data: .data(
                            requestId: item.solarTermId,
                            data: item
                        )
                    ))
                }

                var needsUpdateGroupIds: [String] = []
                for item in [res.prevTermEmptyRecord, res.nextTermEmptyRecord] {
                    guard let item else { continue }

                    let termRecordKey = Self.termRecordKey(item.year, item.term)
                    if let record = state.calendarState.cellContext[termRecordKey], record.data != nil {
                        continue
                    }

                    await send(.updateTermRecordData(
                        id: termRecordKey,
                        data: .noData(requestId: item.solarTermId)
                    ))
                    needsUpdateGroupIds.append(
                        Self.termGroupId(year: item.year, term: item.term)
                    )
                }
                if !needsUpdateGroupIds.isEmpty {
                    await send(.updateRowReloadRequest(
                        .init(targetIds: needsUpdateGroupIds)
                    ))
                }
            } catch {
                if error is CancellationError { return }
                logger.error(message: error.localizedDescription)

                try? await Task.sleep(for: .seconds(2))
                await send(.calendarDataRequest(request))
            }
        }
        .cancellable(id: request, cancelInFlight: true)
    }

    func refreshAnchoredTermData(_ state: State) -> Effect<Action> {
        if let anchorId = state.anchoredTermId,
           let anchoredTerm = findTermGroup(pages: state.calendarState.pages, termGroupId: anchorId) {
            let info = anchoredTerm.solarTermInfo
            let fetchId = Self.termRecordKey(info.year, info.term)

            if let pending = state.calendarState.cellContext[fetchId] {
                let request = TermFetchRequest.specific(id: pending.requestId)
                return .send(.calendarDataRequest(request))
            }
        }
        return .none
    }

    static func termRecordKey(
        _ year: SolarTermYear,
        _ term: SolarTerm
    ) -> String {
        "\(year.rawValue)-\(term.rawValue)"
    }
}
