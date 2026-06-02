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
    private(set) var isInflight: Bool
    var data: CalendarTermRecord?

    private init(requestId: Int, isInflight: Bool, data: CalendarTermRecord? = nil) {
        self.requestId = requestId
        self.isInflight = isInflight
        self.data = data
    }

    mutating func flight() {
        self.isInflight = true
    }
}

extension CalendarTermRecordData {
    static func data(requestId: Int, data: CalendarTermRecord) -> Self {
        CalendarTermRecordData(
            requestId: requestId,
            isInflight: false,
            data: data
        )
    }

    static func noData(requestId: Int) -> Self {
        CalendarTermRecordData(
            requestId: requestId,
            isInflight: false
        )
    }
}
