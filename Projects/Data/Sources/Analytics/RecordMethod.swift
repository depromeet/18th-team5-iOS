//
//  RecordMethod.swift
//  Data
//
//  Created by 이정원 on 6/23/26.
//  Copyright © 2026 Orange. All rights reserved.
//

enum RecordMethod {
    case photoOnly
    case memoOnly
    case both
    case none

    init(hasPhoto: Bool, hasMemo: Bool) {
        self = switch (hasPhoto, hasMemo) {
        case (true, false): .photoOnly
        case (false, true): .memoOnly
        case (true, true): .both
        case (false, false): .none
        }
    }

    var analyticsValue: String {
        switch self {
        case .photoOnly: "photo_only"
        case .memoOnly: "memo_only"
        case .both: "both"
        case .none: "none"
        }
    }
}
