//
//  MissionSearchView.swift
//  Presentation
//
//  Created by 이정원 on 5/24/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct MissionSearchView: View {
    @Bindable private var store: StoreOf<MissionSearchFeature>

    public init(store: StoreOf<MissionSearchFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView
            ScrollView {
                VStack(spacing: 24) {
                    titleView
                    spaceTypeView
                    participationTypeView
                    categoryView
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(height: 390)
            }
            bottomButton
        }
        .background(Color.white)
        .presentationDetents([.height(555)])
    }
}

private extension MissionSearchView {
    var headerView: some View {
        VStack(spacing: 0) {
            indicatorView
                .padding(.vertical, 6)

            ZStack {
                headerTitleView
                    .padding(.horizontal, 64)

                HStack {
                    closeButton
                    Spacer()
                }
                .padding(.leading, 20)
            }
        }
        .padding(.bottom, 16)
    }

    var indicatorView: some View {
        Capsule()
            .frame(width: 36, height: 5)
            .foregroundStyle(Color.gray200)
    }

    var headerTitleView: some View {
        Text("제철 미션 찾기")
            .font(.body1Medium)
            .foregroundStyle(Color.gray900)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
    }

    var closeButton: some View {
        Button {
            store.send(.closeButtonTapped)
        } label: {
            Image.icClose
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.white)
                .padding(12)
                .background(Color.blackAlpha600)
                .clipShape(Circle())
        }
    }

    var titleView: some View {
        VStack(spacing: 4) {
            Text("제철 활동을 찾아볼까요?")
                .font(.headline1Semibold)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("원하는 조건을 기반으로 제철 활동을 추천해드려요!")
                .font(.body2Regular)
                .foregroundStyle(Color.gray600)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var spaceTypeView: some View {
        SearchCategoryGridView(
            title: "공간",
            season: store.season,
            items: LocationType.allCases,
            selection: $store.locationType,
            itemTitle: { $0.name },
            itemImage: { $0.image }
        )
    }

    var participationTypeView: some View {
        SearchCategoryGridView(
            title: "인원",
            season: store.season,
            items: ParticipationType.allCases,
            selection: $store.participationType,
            itemTitle: { $0.name },
            itemImage: { $0.image }
        )
    }

    var categoryView: some View {
        SearchCategoryGridView(
            title: "카테고리",
            season: store.season,
            items: MissionSearchCategory.allCases,
            selection: $store.category,
            itemTitle: { $0.name },
            itemImage: { $0.image }
        )
    }

    var bottomButton: some View {
        BottomButton(title: "확인") {
            store.send(.bottomButtonTapped)
        }
        .disabled(!store.isBottomButtonEnabled)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

extension LocationType {
    var image: Image {
        switch self {
        case .indoor: .icHome
        case .outdoor: .icMountain
        }
    }
}

extension ParticipationType {
    var image: Image {
        switch self {
        case .alone: .icUser
        case .together: .icUserMultiple
        }
    }
}

extension MissionSearchCategory {
    var image: Image {
        switch self {
        case .food: .icFood
        case .nature: .icTree
        case .record: .icSlate
        case .place: .icLocation
        case .music: .icMusic
        }
    }
}
