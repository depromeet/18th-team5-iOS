//
//  PrivacyPolicyView.swift
//  Presentation
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct PrivacyPolicyView: View {
    private let store: StoreOf<PrivacyPolicyFeature>

    public init(store: StoreOf<PrivacyPolicyFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            if let policies = store.privacyPolicies {
                VStack(spacing: 36) {
                    ForEach(policies.indices, id: \.self) { index in
                        privacyPolicyInfoView(policies[index])
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationBar(title: "개인정보처리방침") {
            store.send(.backButtonTapped)
        }
        .background(Color.white)
        .swipeBackEnabled(isEnabled: !store.isLoading)
        .loading(isLoading: store.isLoading)
        .customAlert(store.scope(state: \.alert, action: \.alert))
    }
}

private extension PrivacyPolicyView {
    func privacyPolicyInfoView(_ info: DocumentInfo) -> some View {
        VStack(spacing: 12) {
            if let title = info.title {
                Text(title)
                    .font(.headline2Medium)
                    .foregroundStyle(Color.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }

            Text(info.content)
                .font(.caption1Regular)
                .foregroundStyle(Color.gray700)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
}

extension PrivacyPolicyFeature.Alert: AlertPresentable {
    public var alertInfo: AlertInfo {
        switch self {
        case .fetchFailed:
            AlertInfo(
                icon: .icWarning,
                title: "개인정보처리방침을 불러오지 못했어요.\n 다시 시도해 주세요.",
                primaryButtonTitle: "새로고침",
                secondaryButtonTitle: "닫기"
            )
        }
    }
}
