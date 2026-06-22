//
//  CalendarTermRecordData.swift
//  Presentation
//
//  Created by choijunios on 6/1/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

/// 절기 기록 키(`CalendarFeature.termRecordKey`) → 기록 데이터.
/// `PagingTableView`의 `cellContext`로 전달되어, 기록 변경이 셀 렌더링에 동기화되도록 한다.
public typealias TermRecordContext = [SolarTermGroup.ID: CalendarTermRecordData]

public struct CalendarTermRecordData: Equatable {
    let requestId: Int
    var data: CalendarTermRecord?

    private init(requestId: Int, data: CalendarTermRecord? = nil) {
        self.requestId = requestId
        self.data = data
    }
}

extension CalendarTermRecordData {
    static func data(requestId: Int, data: CalendarTermRecord) -> Self {
        CalendarTermRecordData(
            requestId: requestId,
            data: data
        )
    }

    static func noData(requestId: Int) -> Self {
        CalendarTermRecordData(
            requestId: requestId
        )
    }
}
