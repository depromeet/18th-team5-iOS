//
//  NotificationBanner.swift
//  Presentation
//
//  Created by 이정원 on 6/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct NotificationBanner: View {
    private let mainColor: Color = .init(hex: 0xCC2F26)
    private let backgroundColor: Color = .init(hex: 0xF5E0DF)
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        notificationIcon
                        titleView
                    }

                    messageView
                }

                arrowIcon
            }
            .padding(.horizontal, 16)
            .frame(height: 98)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: .radius12))
        }
    }
}

private extension NotificationBanner {
    var notificationIcon: some View {
        Image.icAlarm
            .renderingMode(.template)
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundStyle(mainColor)
    }

    var titleView: some View {
        Text("알림을 켜주세요")
            .font(.body2Semibold)
            .foregroundStyle(mainColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var messageView: some View {
        let message = """
        다양한 제철 소식을 실시간으로 받을 수 있도록 OS 설정에서 알림을 켜주세요
        """

        return Text(message)
            .font(.body2Regular)
            .foregroundStyle(mainColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }

    var arrowIcon: some View {
        Image.icArrowRight
            .renderingMode(.template)
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundStyle(mainColor)
    }
}
