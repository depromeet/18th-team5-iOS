//
//  CalendarDetailView.swift
//  Presentation
//
//  Created by choijunios on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct CalendarDetailView: View {
    @State var cardIndex: Int = 0

    var body: some View {
        GeometryReader { _ in
            ZStack {
                backgroundView

                VStack {
                    CardStackView(
                        topCardIndex: $cardIndex,
                        items: [
                            DateCard(),
                            DateCard(),
                            DateCard(),
                            DateCard(),
                            DateCard(),
                            DateCard()
                        ]
                    ) { _, _ in
                        EmptyView()
                    }
                    .padding(.top, 16)
                    Spacer()
                }

                bottomButtonContainer
            }
        }
    }
}

// MARK: DetailView

extension CalendarDetailView {
    var backgroundView: some View {
        Color.white
            .overlay {
                VStack {
                    LinearGradient(
                        colors: [
                            .black.opacity(0.05),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 30)
                    Spacer()
                }
            }
            .ignoresSafeArea(.container, edges: [.bottom])
    }

    var bottomButtonContainer: some View {
        VStack(spacing: .zero) {
            Spacer()
            HStack(spacing: 8) {
                Button {
                    // TODO: 액션
                } label: {
                    Text("이미지 저장")
                }
                .buttonStyle(.master(.large))

                Button {
                    // TODO: 액션
                } label: {
                    Text("이미지 공유")
                }
                .buttonStyle(.master(.large))
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    CalendarDetailView()
}
