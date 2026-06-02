//
//  HomeHeaderView.swift
//  Presentation
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct HomeHeaderView: View {
    private let showBlur: Bool
    private let hasUnread: Bool
    private let myPageAction: () -> Void
    private let notificationAction: () -> Void

    init(
        showBlur: Bool,
        hasUnread: Bool,
        myPageAction: @escaping () -> Void,
        notificationAction: @escaping () -> Void
    ) {
        self.showBlur = showBlur
        self.hasUnread = hasUnread
        self.myPageAction = myPageAction
        self.notificationAction = notificationAction
    }

    var body: some View {
        HStack {
            Image.imgPeaktimeLogo
                .resizable()
                .frame(width: 126, height: 24)

            Spacer()

            HStack(spacing: 14) {
                myPageButton
                notificationButton
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .frame(height: 56)
        .background(alignment: .top) {
            BackgroundBlurView()
                .ignoresSafeArea(edges: .top)
                .transition(.opacity)
                .renderedIf(showBlur)
        }
        .animation(.easeInOut(duration: 0.2), value: showBlur)
    }
}

private extension HomeHeaderView {
    var myPageButton: some View {
        Button(action: myPageAction) {
            Image.icPerson
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.gray700)
        }
    }

    var notificationButton: some View {
        Button(action: notificationAction) {
            Image.icAlarm
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.gray700)
                .overlay(alignment: .topTrailing) {
                    Color.systemRed
                        .frame(width: 4, height: 4)
                        .clipShape(Circle())
                        .padding(.trailing, -1)
                        .padding(.top, -1)
                        .renderedIf(hasUnread)
                }
        }
    }
}
