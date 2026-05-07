//  DayDetail.swift
//  Domain
//
//  Created by 송민교 on 5/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct DayDetail: Equatable, Sendable {
    public let date: Date

    public init(date: Date) {
        self.date = date
    }
}
