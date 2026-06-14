//
//  AlertDemoView.swift
//  DesignSystemDemo
//
//  Created by 이정원 on 6/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct AlertDemoView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .opacity(0.5)

            NewCustomAlertView(
                alertInfo: .init(
                    icon: .ic2dCamera,
                    title: "타이틀 예시입니다",
                    primaryButtonTitle: "확인",
                    secondaryButtonTitle: "닫기"
                ),
                primaryAction: {},
                secondaryAction: {}
            )
        }
    }
}
