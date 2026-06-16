//
//  AnnouncementListView.swift
//  Presentation
//
//  Created by 이정원 on 6/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct AnnouncementListView: View {
    @State private var scrollOffset: CGFloat = 0
    @Bindable private var store: StoreOf<AnnouncementListFeature>

    public init(store: StoreOf<AnnouncementListFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if let announcements = store.announcements {
                if announcements.isEmpty { emptyView } else { scrollView(announcements) }
            } else {
                titleView
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationBar(title: navigationTitle, shouldBlur: shouldBlur) {
            store.send(.backButtonTapped)
        }
        .swipeBackEnabled(isEnabled: !store.isLoading)
        .background(Color.white)
        .loading(isLoading: store.isLoading)
        .animation(.easeInOut(duration: 0.2), value: shouldBlur)
        .customAlert(store.scope(state: \.alert, action: \.alert))
        .onAppear { store.send(.onAppear) }
        .navigationDestination(
            item: $store.scope(state: \.detail, action: \.detail),
            destination: AnnouncementDetailView.init
        )
    }
}

private extension AnnouncementListView {
    var shouldBlur: Bool {
        scrollOffset >= 24
    }

    var navigationTitle: String {
        shouldBlur ? "공지사항" : ""
    }
}

private extension AnnouncementListView {
    var emptyView: some View {
        VStack(spacing: 0) {
            titleView

            VStack(spacing: 8) {
                let text = """
                현재 등록된 공지사항이 없어요.
                새로운 소식은 여기서 확인하실 수 있어요.
                """

                Text(text)
                    .font(.body1Medium)
                    .foregroundStyle(Color.gray600)
                    .multilineTextAlignment(.center)

                emptyImageView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var emptyImageView: some View {
        Image.imgNoRecord
            .resizable()
            .frame(width: 200, height: 163)
    }

    func scrollView(_ announcements: [Announcement]) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                titleView
                VStack(spacing: 0) {
                    ForEach(announcements.indices, id: \.self) { index in
                        Button {
                            store.send(.announcementTapped(index))
                        } label: {
                            announcementView(announcements[index])
                        }
                    }
                }
            }
            .padding(.bottom, 56)
            .readScrollOffset { scrollOffset = $0.y }
        }
        .scrollOffsetCoordinateSpace()
    }

    var titleView: some View {
        Text("공지사항")
            .font(.headline1Semibold)
            .foregroundStyle(Color.gray900)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)
    }

    func announcementView(_ announcement: Announcement) -> some View {
        HStack(alignment: .top, spacing: 12) {
            iconView

            VStack(alignment: .leading, spacing: 4) {
                Text(announcement.title)
                    .font(.body1Medium)
                    .foregroundStyle(Color.gray800)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)

                Text(announcement.dateString)
                    .font(.caption1Medium)
                    .foregroundStyle(Color.gray600)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            Color.blackAlpha100
                .frame(height: 1)
        }
    }

    var iconView: some View {
        ZStack {
            Color.gray50
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: .radius12))

            Image.icMegaphone
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
}

extension AnnouncementListFeature.Alert: AlertPresentable {
    public var alertInfo: AlertInfo {
        switch self {
        case .fetchFailed:
            AlertInfo(
                icon: .icWarning,
                title: "공지사항을 불러오지 못했어요.\n 다시 시도해 주세요.",
                primaryButtonTitle: "새로고침",
                secondaryButtonTitle: "닫기"
            )
        }
    }
}
