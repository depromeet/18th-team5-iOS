//
//  MissionCardNavigation.swift
//  Domain
//
//  Created by 이정원 on 6/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct MissionCardNavigation: Equatable {
    public let method: MissionCardNavigationMethod
    public let fromPosition: Int
    public let toPosition: Int

    public init(
        method: MissionCardNavigationMethod,
        fromPosition: Int,
        toPosition: Int
    ) {
        self.method = method
        self.fromPosition = fromPosition
        self.toPosition = toPosition
    }

    public var direction: MissionCardNavigationDirection {
        fromPosition < toPosition ? .next : .previous
    }
}

public enum MissionCardNavigationMethod {
    case tab
    case indicator
    case scroll
}

public enum MissionCardNavigationDirection {
    case next
    case previous
}
