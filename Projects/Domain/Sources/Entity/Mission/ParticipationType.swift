//
//  ParticipationType.swift
//  Domain
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public enum ParticipationType: CaseIterable {
    case alone
    case together

    public var name: String {
        switch self {
        case .alone: "혼자"
        case .together: "같이"
        }
    }
}
