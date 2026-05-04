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
        Button {
            store.send(.agreeButtonTapped)
        } label: {
            Text("네, 확인했어요")
                .font(.body2Medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(Color(hex: 0xF9FAFB))
                .background(Color(hex: 0x1F2937))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
