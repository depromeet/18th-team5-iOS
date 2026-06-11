//
//  AnnouncementDetailFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct AnnouncementDetailFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        let announcement: Announcement

        public init(_ announcement: Announcement) {
            self.announcement = announcement
        }
    }

    public enum Action {
        case backButtonTapped
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            }
        }
    }
}
