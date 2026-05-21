//
//  MissionListView.swift
//  Presentation
//
//  Created by 이정원 on 5/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct MissionListView: View {
    @Bindable private var store: StoreOf<MissionListFeature>

    public init(store: StoreOf<MissionListFeature>) {
        self.store = store
    }

    public var body: some View {
        Color.white
            .overlay(alignment: .top) { headerView }
    }
}

private extension MissionListView {
    var headerView: some View {
        VStack(spacing: 20) {
            titleView

            HStack(spacing: 0) {
                categoryListView
                Spacer()
                searchButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 12)
    }

    var titleView: some View {
        VStack(spacing: 2) {
            Text("\(store.nickname)님을 위한")
                .font(.body1Regular)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(store.solarTerm.koreanName) 미션을 기록해볼까요?")
                .font(.headline1Semibold)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var categoryListView: some View {
        HStack(spacing: 6) {
            ForEach(
                MissionListFeature.Category.allCases,
                id: \.self
            ) { category in
                categoryView(category)
            }
        }
    }

    func categoryView(
        _ category: MissionListFeature.Category
    ) -> some View {
        Chip(
            title: category.title,
            type: category == store.category ? .default : .secondary,
            action: { store.send(.set(\.category, category)) }
        )
    }

    var searchButton: some View {
        EmptyView()
    }
}

private extension MissionListFeature.Category {
    var title: String {
        switch self {
        case .all: "전체"
        case .food: "음식"
        case .contents: "콘텐츠"
        case .activity: "활동"
        }
    }
}
