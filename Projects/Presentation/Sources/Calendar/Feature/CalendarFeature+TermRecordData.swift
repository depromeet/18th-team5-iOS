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
                    try await calendarRecordRepository.fetchSolarTerms(solarTermId: id)
                }

                for item in res.fetchedTermRecords {
                    await send(.updateTermRecordData(
                        id: createDataId(item.year, item.term),
                        data: .data(
                            requestId: item.solarTermId,
                            data: item
                        )
                    ))
                }

                for item in [res.prevTermEmptyRecord, res.nextTermEmptyRecord] {
                    guard let item else { continue }

                    let dataId = createDataId(item.year, item.term)
                    if let record = state.termRecordData[dataId] {
                        if record.data != nil || record.isInflight {
                            continue
                        }
                    }

                    await send(.updateTermRecordData(
                        id: dataId,
                        data: .noData(requestId: item.solarTermId)
                    ))
                }
            } catch {
                logger.error(message: error.localizedDescription)
            }
        }
    }

    func createDataId(_ year: SolarTermYear, _ term: SolarTerm) -> String {
        "\(year.rawValue)-\(term.rawValue)"
    }
}
