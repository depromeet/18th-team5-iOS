//
//  NotificationConsentView.swift
//  Presentation
//
//  Created by Claude on 4/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct NotificationConsentView: View {
    private let store: StoreOf<NotificationConsentFeature>

    public init(store: StoreOf<NotificationConsentFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 48) {
                VStack(spacing: 12) {
                    Image.icAlarmClock
                        .resizable()
                        .frame(width: 48, height: 48)

                    Text(title)
                        .font(.headline2Semibold)
                        .foregroundStyle(Color.gray900)
                        .multilineTextAlignment(.center)
                }

                Image.imgNotificationGuide
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 16) {
                nextButton
                skipButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(LinearGradient.onboardingBackground)
    }
}

private extension NotificationConsentView {
    var title: String {
        """
        알림을 허용하면, 절기를 놓치지 않고
        미션에도 쉽게 참여할 수 있어요!
        """
    }

    var nextButton: some View {
        BottomButton(title: "다음") {
            store.send(.nextButtonTapped)
        }
    }

    var skipButton: some View {
        Button {
            store.send(.skipButtonTapped)
        } label: {
            HStack(spacing: 0) {
                Text("건너뛰기")
                    .font(.body1Medium)
                    .foregroundStyle(Color.gray600)

                Image.icArrowRight
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.gray600)
            }
        }
    }
}
