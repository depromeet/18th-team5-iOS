//
//  FontDemoView.swift
//  DesignSystemDemo
//
//  Created by 이정원 on 5/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct FontDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(Typography.allCases, id: \.self) { typography in
                    Text("피크타임에서 오늘의 절기 미션에 참여볼까요?")
                        .font(typography)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .border(Color.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        }
        .navigationTitle("Font")
    }
}
