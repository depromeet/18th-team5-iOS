//
//  AnnouncementListFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct AnnouncementListFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        var announcements: [Announcement]?
        var isLoading: Bool = false
        @Presents var detail: AnnouncementDetailFeature.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case announcementsFetched([Announcement])
        case backButtonTapped
        case announcementTapped(Int)
        case detail(PresentationAction<AnnouncementDetailFeature.Action>)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    try await Task.sleep(for: .seconds(1))
                    await send(.announcementsFetched(.sample))
                }
            case let .announcementsFetched(announcements):
                state.announcements = announcements
                state.isLoading = false
                return .none
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            case let .announcementTapped(index):
                let announcement = state.announcements?[index]
                guard let announcement else { return .none }
                state.detail = .init(announcement)
                return .none
            case .detail: return .none
            }
        }
        .ifLet(\.$detail, action: \.detail) {
            AnnouncementDetailFeature()
        }
    }
}

private extension [Announcement] {
    // TODO: 이후 PR에서 제거 예정 - @정원
    static let sample: Self = [
        .init(
            title: "제목 두 줄일 때 예시입니다. 최대 40자까지 입력할 수 있습니다.",
            content: .sample,
            date: .now.addingTimeInterval(-10)
        ),
        .init(
            title: "제목 한 줄일 때 예시입니다.",
            content: .sample,
            date: .now.addingTimeInterval(-16 * 60)
        ),
        .init(
            title: "제목 두 줄일 때 예시입니다. 최대 40자까지 입력할 수 있습니다.",
            content: .sample,
            date: .now.addingTimeInterval(-9 * 60 * 60)
        ),
        .init(
            title: "제목 한 줄일 때 예시입니다.",
            content: .sample,
            date: .now.addingTimeInterval(-23 * 60 * 60)
        ),
        .init(
            title: "제목 한 줄일 때 예시입니다.",
            content: .sample,
            date: .now.addingTimeInterval(-4 * 60 * 60 * 24)
        ),
        .init(
            title: "제목 두 줄일 때 예시입니다. 최대 40자까지 입력할 수 있습니다.",
            content: .sample,
            date: .now.addingTimeInterval(-5 * 60 * 60 * 24)
        ),
        .init(
            title: "제목 한 줄일 때 예시입니다.",
            content: .sample,
            date: .now.addingTimeInterval(-6 * 60 * 60 * 24)
        ),
        .init(
            title: "제목 두 줄일 때 예시입니다. 최대 40자까지 입력할 수 있습니다.",
            content: .sample,
            date: .now.addingTimeInterval(-14 * 60 * 60 * 24)
        ),
        .init(
            title: "제목 한 줄일 때 예시입니다.",
            content: .sample,
            date: .now.addingTimeInterval(-30 * 60 * 60 * 24)
        ),
        .init(
            title: "제목 한 줄일 때 예시입니다.",
            content: .sample,
            date: .now.addingTimeInterval(-180 * 60 * 60 * 24)
        )
    ]
}

private extension String {
    static let sample: Self = """
    안녕하세요. 피크타임입니다.
    고객님께 안정적인 서비스를 제공하기 위한
    정기 시스템 점검이 있습니다.
    정기점검 시간 중에는 시스템이 정상작동 하지 않을 수 있으니,
    서비스 점검시간을 확인하시기 바랍니다.
    안녕하세요. 피크타임입니다.
    고객님께 안정적인 서비스를 제공하기 위한
    정기 시스템 점검이 있습니다.
    정기점검 시간 중에는 시스템이 정상작동 하지 않을 수 있으니,
    서비스 점검시간을 확인하시기 바랍니다.
    """
}
