//
//  Season.swift
//  Domain
//
//  Created by 송민교 on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public enum Season: String, CaseIterable, Hashable {
    case spring
    case summer
    case autumn
    case winter

    public var displayName: String {
        switch self {
        case .spring: "봄"
        case .summer: "여름"
        case .autumn: "가을"
        case .winter: "겨울"
        }
    }
}
