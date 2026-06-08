//
//  CalendarDetailView.swift
//  Presentation
//
//  Created by choijunios on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

struct CalendarDetailView: View {
    @Bindable var store: StoreOf<CalendarDetailFeature>
    @State var frontCardIndex: Int = 0
    @State var screenSize: CGSize = .zero

    var cards: [DateCard] {
        store.cards
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                backgroundView
                    .onGeometryChange(
                        for: CGSize.self,
                        of: { $0.size }
                    ) { screenSize = $0 }

                VStack {
                    CardStackView(
                        topCardIndex: $frontCardIndex,
                        items: cards
                    ) { index, _ in
                        cardView(index: index)
                    }
                    .padding(.top, 16)
                    Spacer()
                }

                bottomButtonContainer
            }
            .presentToast($store.toast)
            .toastContainer()
        }
    }
}

// MARK: Background

private extension CalendarDetailView {
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
}

// MARK: Bottom button

private extension CalendarDetailView {
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

extension CalendarDetailFeature.Alert: AlertPresentable {
    public var alertInfo: AlertInfo {
        switch self {
        case .removeCard:
            return AlertInfo(
                title: "기록을 삭제할까요?",
                primaryButtonTitle: "확인",
                secondaryButtonTitle: "닫기"
            )
        }
    }
}

#Preview {
    CalendarDetailView(
        store: .init(initialState: .init()) {
            CalendarDetailFeature()
        }
    )
}
