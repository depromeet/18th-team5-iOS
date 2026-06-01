//
//  CalendarDetail.swift
//  Presentation
//
//  Created by choijunios on 5/23/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

// TODO: 임시모델 -@준영
public struct CalendarDetail: Identifiable, Equatable {
    public let id = UUID()
    public let cards: [CalendarDetailCard]
}

// TODO: 임시모델 -@준영
public struct CalendarDetailCard: Identifiable, Equatable {
    public let id: UUID = .init()
    public let name: String
}
