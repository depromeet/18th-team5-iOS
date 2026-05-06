//
//  OnboardingSurveyView.swift
//  Presentation
//
//  Created by 이정원 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct OnboardingSurveyView: View {
    @Bindable private var store: StoreOf<OnboardingSurveyFeature>

    public init(store: StoreOf<OnboardingSurveyFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch store.status {
                case .ready: OnboardingReadyView()
                case .inProgress: surveyView
                case .result: Spacer()
                }
            }
            .animation(.easeInOut, value: store.status)

            bottomButton
        }
    }
}

private extension OnboardingSurveyView {
    var title: String {
        switch store.step {
        case 0: "갑자기 생긴 쉬는 날,\n어떻게 보내고 싶으세요?"
        case 1: "계절 활동,\n어떤 방식이 더 잘 맞아요?"
        case 2: "계절을 주로 어떻게 즐기는 편이에요?"
        default: ""
        }
    }

    var subtitle: String {
        "(선호하는 순서대로 순위를 매겨 주세요)"
    }

    func optionTitle(_ selection: OnboardingSurveyFeature.Selection) -> String {
        return switch (store.step, selection) {
        case (0, .left): "밖에 나가서\n뭔가 하고 싶어요"
        case (0, .right): "집이나 실내에서\n편하게 쉬고 싶어요"
        case (1, .left): "시간 내서\n적극적으로"
        case (1, .right): "일상 안에서\n부담 없이"
        default: ""
        }
    }

    func optionSubtitle(_ selection: OnboardingSurveyFeature.Selection) -> String {
        return switch (store.step, selection) {
        case (0, .left): "야외, 나들이, 장소\n방문 선호"
        case (0, .right): "카페, 요리, 콘텐츠\n소비 선호"
        case (1, .left): "원거리 이동,\n새로운 장소 방문 OK"
        case (1, .right): "동네 범위,\n이동 없이 5분이면 완료"
        default: ""
        }
    }

    var selection: Binding<OnboardingSurveyFeature.Selection?> {
        switch store.step {
        case 0: $store.firstSelection
        default: $store.secondSelection
        }
    }

    var buttonTitle: String {
        switch store.status {
        case .ready, .result: "시작하기"
        case .inProgress:
            store.step == 2 ? "완료" : "다음"
        }
    }

    var isButtonEnabled: Bool {
        switch store.status {
        case .ready, .result: true
        case .inProgress:
            switch store.step {
            case 0: store.firstSelection != nil
            case 1: store.secondSelection != nil
            default: true
            }
        }
    }
}

private extension OnboardingSurveyView {
    var surveyView: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                VStack(spacing: 40) {
                    titleView

                    if store.step < 2 {
                        selectionView
                    } else if store.step == 2 {
                        EmptyView() // TODO: @정원 - 구현 예정
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
    }

    var headerView: some View {
        ZStack {
            OnboardingProgressView(
                stepCount: store.stepCount,
                currentStep: store.step
            )

            HStack {
                backButton
                Spacer()
            }
            .padding(.leading, 20)
        }
        .frame(height: 56)
    }

    var backButton: some View {
        Button {
            store.send(.backButtonTapped)
        } label: {
            Image.icArrowLeft
                .resizable()
                .frame(width: 24, height: 24)
        }
    }

    var titleView: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.headline1Semibold)
                .foregroundStyle(Color.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)

            if store.step == 2 {
                Text(subtitle)
                    .font(.body2Regular)
                    .foregroundStyle(Color(hex: 0x9CA3AF))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    var selectionView: some View {
        OnboardingSelectionView(
            title: optionTitle,
            subtitle: optionSubtitle,
            selection: selection
        )
    }

    var bottomButton: some View {
        BottomButton(title: buttonTitle) {
            store.send(.bottomButtonTapped)
        }
        .disabled(!isButtonEnabled)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}
