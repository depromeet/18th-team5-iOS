//
//  MenuListView.swift
//  Presentation
//
//  Created by 이정원 on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct MenuListView: View {
    private let menuList: [MyPageFeature.Menu] = [
        .announcements, .contactUs, .termsOfService, .privacyPolicy
    ]

    private let action: (MyPageFeature.Menu) -> Void

    init(action: @escaping (MyPageFeature.Menu) -> Void) {
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            notificationSettingsMenuView
            menuListView
        }
    }
}

private extension MenuListView {
    var notificationSettingsMenuView: some View {
        Button {
            action(.notificationSettings)
        } label: {
            menuView(.notificationSettings)
                .frame(height: 60)
                .padding(.horizontal, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: .radius12))
        }
    }

    var menuListView: some View {
        VStack(spacing: 0) {
            ForEach(menuList, id: \.self) { menu in
                Button {
                    action(menu)
                } label: {
                    ZStack(alignment: .bottom) {
                        menuView(menu)
                            .frame(height: 64)

                        Color.gray100
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .renderedIf(menu != menuList.last)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.vertical, 4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: .radius12))
    }

    func menuView(_ menu: MyPageFeature.Menu) -> some View {
        HStack(spacing: 16) {
            Text(menu.name)
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image.icArrowRight
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.gray500)
        }
    }
}

private extension MyPageFeature.Menu {
    var name: String {
        switch self {
        case .notificationSettings: "알림 수신 설정"
        case .announcements: "공지사항"
        case .contactUs: "문의하기"
        case .termsOfService: "이용약관"
        case .privacyPolicy: "개인정보처리방침"
        }
    }
}
