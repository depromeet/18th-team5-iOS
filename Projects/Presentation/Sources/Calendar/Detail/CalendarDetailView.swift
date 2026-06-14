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
import UIKit

struct CalendarDetailView: View {
    @Bindable var store: StoreOf<CalendarDetailFeature>
    @State var screenSize: CGSize = .zero

    var body: some View {
        ZStack {
            backgroundView
                .onGeometryChange(
                    for: CGSize.self,
                    of: { $0.size }
                ) { screenSize = $0 }

            switch store.displayType {
            case .currentTerm:
                if !store.dateRecordCards.isEmpty {
                    VStack {
                        CardStackView(
                            topCardIndex: $store.frontCardIndex,
                            items: store.dateRecordCards
                        ) { cardIndex, orderIndex, item in
                            cardView(
                                cardIndex: cardIndex,
                                orderIndex: orderIndex,
                                card: item
                            )
                        }
                        .padding(.top, 16)
                        Spacer()
                    }
                    .clipped()
                    .transition(.opacity)

                    bottomButtonContainer
                } else {
                    currentTermNoRecordView {
                        store.send(.createRecordButtonTapped)
                    }
                }

            case .passedTerm:
                passedTermNoRecordView

            case .futureTerm:
                futureTermRecordView

            case .notDetermined:
                EmptyView()
            }
        }
        .animation(.easeInOut, value: store.isLoading)
        .presentToast($store.toast)
        .sheet(item: $store.shareImageItem) { item in
            if let image = UIImage(data: item.imageData) {
                ActivityView(activityItems: [image]) { completed in
                    store.send(.shareCompleted(completed))
                }
            } else {
                // 이미지 디코딩 실패 시 빈 시트가 남지 않도록 즉시 닫고 사용자에게 알린다.
                Color.clear
                    .onAppear {
                        store.send(.shareCompleted(false))
                        store.send(.updateToast(.init(title: "이미지 공유에 실패했어요", duration: 1.5, bottomInset: 108)))
                    }
            }
        }
        .overlay {
            if store.isLoading {
                ZStack {
                    Color.gray200.opacity(0.3)
                    ProgressView()
                }
            }
        }
        .task(id: store.date.description) {
            try? await Task.sleep(for: .seconds(0.5))
            guard !Task.isCancelled else { return }
            store.send(.viewDidLoad)
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
                    store.send(.saveImageButtonTapped)
                } label: {
                    Text("이미지 저장")
                }
                .buttonStyle(.master(.large))

                Button {
                    store.send(.shareImageButtonTapped)
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

        case .fetchRecordFailure:
            return AlertInfo(
                title: "기록 획득에 실패했어요",
                primaryButtonTitle: "재시도 하기",
                secondaryButtonTitle: "닫기"
            )
        }
    }
}
