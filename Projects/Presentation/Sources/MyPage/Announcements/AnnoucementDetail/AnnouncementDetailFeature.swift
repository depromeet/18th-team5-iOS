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
    @Dependency(\.myPageRepository) private var myPageRepository

    @ObservableState
    public struct State: Equatable {
        var announcement: Announcement
        var isLoading: Bool = false

        public init(_ announcement: Announcement) {
            self.announcement = announcement
        }
    }

    public enum Action {
        case onAppear
        case backButtonTapped
        case announcementFetched(Announcement?)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { [state] send in
                    await fetchAnnouncement(state, send)
                }
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            case let .announcementFetched(announcement):
                state.isLoading = false
                guard let announcement else { return .none }
                state.announcement = announcement
                return .none
            }
        }
    }
}

private extension AnnouncementDetailFeature {
    func fetchAnnouncement(_ state: State, _ send: Send<Action>) async {
        do {
            let id = state.announcement.id
            let announcement = try await myPageRepository.fetchAnnouncement(id)
            await send(.announcementFetched(announcement))
        } catch {
            // TODO: 에러 처리 - @정원
        }
    }
}
