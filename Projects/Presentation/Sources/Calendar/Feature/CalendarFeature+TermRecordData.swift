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

extension CalendarFeature {
    enum TermFetchRequest {
        case today
        case specific(id: Int)
    }

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
                    if let record = state.termRecordData[termRecordKey] {
                        if record.data != nil || record.isInflight {
                            continue
                        }
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
                // TODO: 에러처리 -@준영
                logger.error(message: error.localizedDescription)
            }
        }
    }

    static func termRecordKey(
        _ year: SolarTermYear,
        _ term: SolarTerm
    ) -> String {
        "\(year.rawValue)-\(term.rawValue)"
    }
}
