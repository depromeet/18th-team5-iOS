//
//  AnnouncementListFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Core
import Domain

@Reducer
public struct AnnouncementListFeature {
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.myPageRepository) private var myPageRepository

    @ObservableState
    public struct State: Equatable {
        var announcements: [Announcement]?
        var isLoading: Bool = false
        var alert: CustomAlertFeature<Alert>.State?
        @Presents var detail: AnnouncementDetailFeature.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case announcementsFetched([Announcement])
        case backButtonTapped
        case announcementTapped(Int)
        case showAlert(Alert)
        case alert(CustomAlertFeature<Alert>.Action)
        case detail(PresentationAction<AnnouncementDetailFeature.Action>)
    }

    public enum Alert {
        case fetchFailed
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await fetchAnnouncements(send)
                }
            case let .announcementsFetched(announcements):
                state.announcements = announcements
                state.isLoading = false
                return .none
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            case let .announcementTapped(index):
                let announcement = state.announcements?[safe: index]
                guard let announcement else { return .none }
                state.detail = .init(announcement)
                return .none
            case let .showAlert(alert):
                state.isLoading = false
                state.alert = .init(alert)
                return .none
            case .alert(.primaryButtonTapped):
                state.alert = nil
                return .send(.onAppear)
            case .alert(.secondaryButtonTapped):
                return .send(.backButtonTapped)
            case .detail: return .none
            case .alert: return .none
            }
        }
        .ifLet(\.$detail, action: \.detail) {
            AnnouncementDetailFeature()
        }
        .ifLet(\.alert, action: \.alert) {
            CustomAlertFeature()
        }
    }
}

private extension AnnouncementListFeature {
    func fetchAnnouncements(_ send: Send<Action>) async {
        do {
            let announcements = try await myPageRepository.fetchAnnouncements()
            await send(.announcementsFetched(announcements))
        } catch {
            await send(.showAlert(.fetchFailed))
        }
    }
}
