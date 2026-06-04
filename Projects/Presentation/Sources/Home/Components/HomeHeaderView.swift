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
    private let myPageAction: () -> Void

    init(
        showBlur: Bool,
        myPageAction: @escaping () -> Void
    ) {
        self.showBlur = showBlur
        self.myPageAction = myPageAction
    }

    var body: some View {
        HStack {
            Image.imgPeaktimeLogo
                .resizable()
                .frame(width: 126, height: 24)
                .padding(.leading, 20)

            Spacer()
            myPageButton
        }
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
                .padding(.horizontal, 20)
        }
    }
}
