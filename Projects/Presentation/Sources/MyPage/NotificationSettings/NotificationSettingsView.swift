//
//  NotificationSettingsView.swift
//  Presentation
//
//  Created by 이정원 on 6/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct NotificationSettingsView: View {
    @Bindable private var store: StoreOf<NotificationSettingsFeature>

    public init(store: StoreOf<NotificationSettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                notificationBanner
                toggleListView
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .navigationBar(title: "알림 수신 설정") { store.send(.backButtonTapped) }
        .background(Color.gray100)
    }
}

private extension NotificationSettingsView {
    func isOn(_ type: NotificationType) -> Binding<Bool>? {
        guard let settings = Binding($store.settings) else { return nil }
        return Binding(settings[type])
    }
}

private extension NotificationSettingsView {
    var notificationBanner: some View {
        NotificationBanner {
            store.send(.bannerTapped)
        }
        .renderedIf(false)
    }

    var toggleListView: some View {
        VStack(spacing: 0) {
            let allNotificationTypes = NotificationType.allCases
            ForEach(allNotificationTypes, id: \.self) { type in
                ZStack(alignment: .bottom) {
                    toggleItemView(title: type.name, isOn: isOn(type))

                    Color.gray100
                        .frame(height: 1)
                        .renderedIf(type != allNotificationTypes.last)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: .radius12))
    }

    func toggleItemView(title: String, isOn: Binding<Bool>?) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)

            Spacer()

            if let isOn {
                CustomToggle(
                    isOn: isOn,
                    mainColor: store.season.color(.scale600)
                )
                .disabled(false)
            }
        }
        .frame(height: 60)
    }
}

private extension NotificationType {
    var name: String {
        switch self {
        case .solarTermStart: "절기 시작"
        case .solarTermEnd: "절기 마무리"
        case .dailyMission: "오늘의 미션"
        }
    }
}
