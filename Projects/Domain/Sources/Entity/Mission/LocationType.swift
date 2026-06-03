//
//  LocationType.swift
//  Domain
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public enum LocationType: CaseIterable {
    case indoor
    case outdoor

    public var name: String {
        switch self {
        case .indoor: "실내"
        case .outdoor: "실외"
        }
    }
}
