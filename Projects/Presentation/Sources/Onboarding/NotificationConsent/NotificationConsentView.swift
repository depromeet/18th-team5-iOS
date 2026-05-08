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
            VStack(spacing: 56) {
                Text("절기 알림과 미션을 위해\n알림 허용이 필요해요")
                    .font(.headline2Semibold)
                    .foregroundStyle(Color.gray800)
                    .multilineTextAlignment(.center)

                Image.imgNotificationGuide
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            doneButton
        }
    }
}

private extension NotificationConsentView {
    var doneButton: some View {
        BottomButton(title: "네, 확인했어요") {
            store.send(.agreeButtonTapped)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
