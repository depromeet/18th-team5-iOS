//
//  MissionSearchResultView.swift
//  Presentation
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct MissionSearchResultView: View {
    private let store: StoreOf<MissionSearchResultFeature>

    public init(store: StoreOf<MissionSearchResultFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 0) {
                headerView

                Spacer()
                VStack(spacing: 56) {
                    textView
                    graphicView
                    categoryListView
                }
                Spacer()

                bottomButton
            }
        }
        .navigationBarBackButtonHidden()
    }
}

private extension MissionSearchResultView {
    var backgroundView: some View {
        LinearGradient.background(store.season)
            .ignoresSafeArea()
    }

    var headerView: some View {
        ZStack {
            Text("제철 미션 찾기")
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 60)

            HStack {
                Button {
                    store.send(.backButtonTapped)
                } label: {
                    Image.icArrowLeft
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.gray800)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 56)
    }

    var textView: some View {
        VStack(spacing: 20) {
            Text("결과")
                .font(.body2Medium)
                .foregroundStyle(Color.white)
                .frame(height: 30)
                .padding(.horizontal, 12)
                .background(store.season.color(.scale600))
                .clipShape(Capsule())

            VStack(spacing: 4) {
                Text("선택하신 조건에 맞는 제철 활동을 찾았어요!")
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray600)

                Text("\(store.solarTerm.koreanName) 레시피북 제작")
                    .font(.title2Semibold)
                    .foregroundStyle(Color.gray900)
            }
        }
    }

    // TODO: 임시 뷰. 추후 삭제 예정 - 정원
    var graphicView: some View {
        Text("Graphic")
            .font(.headline1Semibold)
            .foregroundStyle(Color.gray400)
            .frame(width: 200, height: 200)
            .background(Color.gray200)
    }

    var categoryListView: some View {
        HStack(spacing: 8) {
            locationTypeView
            participantTypeView
            categoryView
        }
        .disabled(true)
    }

    var locationTypeView: some View {
        SearchCategoryChipView(
            title: store.locationType.name,
            image: store.locationType.image,
            season: store.season
        )
    }

    var participantTypeView: some View {
        SearchCategoryChipView(
            title: store.participationType.name,
            image: store.participationType.image,
            season: store.season
        )
    }

    var categoryView: some View {
        SearchCategoryChipView(
            title: store.category.name,
            image: store.category.image,
            season: store.season
        )
    }

    var bottomButton: some View {
        BottomButton(title: "미션 기록하기") {}
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
    }
}
