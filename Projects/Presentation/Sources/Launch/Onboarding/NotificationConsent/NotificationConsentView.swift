//
//  NotificationConsentView.swift
//  Presentation
//
//  Created by Claude on 4/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct NotificationConsentView: View {
    private let store: StoreOf<NotificationConsentFeature>

    public init(store: StoreOf<NotificationConsentFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("알림을 허용하면\n중요한 소식을 받아볼 수 있어요")
                .multilineTextAlignment(.center)
                .font(.title3.bold())

            Spacer()

            VStack(spacing: 12) {
                Button {
                    store.send(.agreeButtonTapped)
                } label: {
                    Text("동의하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    store.send(.disagreeButtonTapped)
                } label: {
                    Text("동의하지 않기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .navigationBarBackButtonHidden(true)
    }
}
