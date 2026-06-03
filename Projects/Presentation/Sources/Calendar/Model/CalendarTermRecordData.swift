//
//  CalendarTermRecordData.swift
//  Presentation
//
//  Created by choijunios on 6/1/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

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
