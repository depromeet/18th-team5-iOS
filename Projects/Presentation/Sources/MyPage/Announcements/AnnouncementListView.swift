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
    @Bindable private var store: StoreOf<AnnouncementListFeature>

    public init(store: StoreOf<AnnouncementListFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                titleView
                VStack(spacing: 0) {
                    ForEach(store.announcements.indices, id: \.self) { index in
                        Button {
                            store.send(.announcementTapped(index))
                        } label: {
                            announcementView(store.announcements[index])
                        }
                    }
                }
            }
            .padding(.bottom, 56)
        }
        .navigationBar(title: "") { store.send(.backButtonTapped) }
        .background(Color.white)
        .navigationDestination(
            item: $store.scope(state: \.detail, action: \.detail),
            destination: AnnouncementDetailView.init
        )
    }
}

private extension AnnouncementListView {
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
