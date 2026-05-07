//
//  OnboardingSurveyView.swift
//  Presentation
//
//  Created by 이정원 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
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
                case .initial: initialView
                case .inProgress: surveyView
                case .result: resultView
                }
            }
            .animation(.easeInOut, value: store.status)

            bottomButton
        }
        .background(background)
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

    var buttonTitle: String {
        switch store.status {
        case .initial, .inProgress: "확인"
        case .result: "시작하기"
        }
    }

    var isButtonEnabled: Bool {
        switch store.status {
        case .initial, .result: true
        case .inProgress:
            switch store.step {
            case 0: store.preference.activityStyle != nil
            case 1: store.preference.engagementLevel != nil
            case 2: store.preference.themeRanking.count == 3
            default: false
            }
        }
    }
}

private extension OnboardingSurveyView {
    var initialView: some View {
        OnboardingInitialView()
    }

    var surveyView: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                VStack(spacing: 40) {
                    titleView

                    if store.step < 2 {
                        selectionView
                    } else if store.step == 2 {
                        rankingView
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
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            if store.step == 2 {
                Text(subtitle)
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray600)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    var selectionView: some View {
        switch store.step {
        case 0: activityStyleSelectionView
        default: engagementLevelSelectionView
        }
    }

    var activityStyleSelectionView: some View {
        OnboardingSelectionView(
            items: [.outdoor, .indoor],
            viewState: { $0.viewState },
            selection: $store.preference.activityStyle
        )
    }

    var engagementLevelSelectionView: some View {
        OnboardingSelectionView(
            items: [.active, .casual],
            viewState: { $0.viewState },
            selection: $store.preference.engagementLevel
        )
    }

    var rankingView: some View {
        OnboardingRankingView(
            items: [.nature, .food, .culture],
            ranking: $store.preference.themeRanking,
            viewState: { $0.viewState }
        )
    }

    @ViewBuilder
    var resultView: some View {
        if let userType = store.userType {
            OnboardingResultView(userType: userType)
        }
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

    @ViewBuilder
    var background: some View {
        switch store.status {
        case .initial, .result:
            LinearGradient.onboardingBackground
                .ignoresSafeArea()
        case .inProgress: Color.white
        }
    }
}

private extension ActivityStyle {
    var viewState: OnboardingViewState {
        switch self {
        case .outdoor:
            .init(
                title: "밖에 나가서\n뭔가 하고 싶어요",
                subtitle: "야외, 나들이, 장소\n방문 선호",
                image: .icHandballPlayer
            )
        case .indoor:
            .init(
                title: "집이나 실내에서\n편하게 쉬고 싶어요",
                subtitle: "카페, 요리, 콘텐츠\n소비 선호",
                image: .icSofaAndLamp
            )
        }
    }
}

private extension EngagementLevel {
    var viewState: OnboardingViewState {
        return switch self {
        case .active:
            .init(
                title: "시간 내서\n적극적으로",
                subtitle: "원거리 이동,\n새로운 장소 방문 OK",
                image: .icCar
            )
        case .casual:
            .init(
                title: "일상 안에서\n부담 없이",
                subtitle: "동네 범위,\n이동 없이 5분이면 완료",
                image: .icWalkingWoman
            )
        }
    }
}

private extension ActivityTheme {
    var viewState: OnboardingViewState {
        switch self {
        case .nature:
            .init(
                title: "자연이나 야외 활동",
                subtitle: "봄나들이, 단풍 구경, 산책 등",
                image: .icPineTree
            )
        case .food:
            .init(
                title: "제철 음식이나 요리",
                subtitle: "봄나물, 제철 과일, 계절 음료 등",
                image: .icFryingPan
            )
        case .culture:
            .init(
                title: "감성 콘텐츠나 문화",
                subtitle: "전시, 독서, 영화, 음악 등",
                image: .icMovieProjecter
            )
        }
    }
}
