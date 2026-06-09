//
//  AnnouncementDetailView.swift
//  Presentation
//
//  Created by 이정원 on 6/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct AnnouncementDetailView: View {
    private let store: StoreOf<AnnouncementDetailFeature>

    public init(store: StoreOf<AnnouncementDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                contentView
            }
        }
        .navigationBar(title: "공지사항") { store.send(.backButtonTapped) }
        .background(Color.white)
    }
}

private extension AnnouncementDetailView {
    var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.announcement.title)
                .font(.body1Medium)
                .foregroundStyle(Color.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(store.announcement.dateString)
                .font(.caption1Medium)
                .foregroundStyle(Color.gray600)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            Color.blackAlpha100
                .frame(height: 1)
        }
    }

    var contentView: some View {
        Text(store.announcement.content)
            .font(size: 14, weight: .regular, lineHeight: 24)
            .foregroundStyle(Color.gray900)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 56)
    }
}
