//
//  MyPageView.swift
//  Presentation
//
//  Created by 이정원 on 6/2/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct MyPageView: View {
    @Environment(\.openURL) private var openURL
    @Bindable private var store: StoreOf<MyPageFeature>

    public init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                MenuListView { menu in
                    switch menu {
                    case .contactUs:
                        if let url = store.contactUsURL { openURL(url) }
                    default:
                        store.send(.menuTapped(menu))
                    }
                }

                versionInfoView
                deleteButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .navigationBar(title: "마이페이지") { store.send(.backButtonTapped) }
        .background { backgroundView }
        .onAppear { store.send(.onAppear) }
        .customAlert(store.scope(state: \.alert, action: \.alert))
        .navigationDestination(
            item: $store.scope(state: \.path, action: \.path),
            destination: pathView
        )
    }
}

private extension MyPageView {
    var versionInfoView: some View {
        HStack(spacing: 12) {
            Text("버전")
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(store.currentVersion.string)
                .font(.body2Regular)
                .foregroundStyle(Color.gray600)

            Button {
                if let url = store.storeURL { openURL(url) }
            } label: {
                Text("업데이트")
                    .font(.body2Medium)
                    .foregroundStyle(Color.gray50)
                    .padding(.horizontal, 12)
                    .frame(height: 32)
                    .background(Color.gray700)
                    .clipShape(RoundedRectangle(cornerRadius: .radius8))
            }
            .renderedIf(store.canUpdate)
        }
        .padding(.horizontal, 16)
        .frame(height: 68)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: .radius12))
    }

    var deleteButton: some View {
        Button {
            store.send(.deleteButtonTapped)
        } label: {
            HStack(spacing: 0) {
                Text("내 정보 초기화")
                    .font(.body2Medium)
                    .foregroundStyle(Color.gray600)

                Image.icArrowRight
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.gray600)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    var backgroundView: some View {
        LinearGradient(
            stops: [
                .init(color: store.season.color(.scale50), location: 0.0),
                .init(color: .gray50, location: 0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

extension MyPageFeature.Alert: AlertPresentable {
    public var alertInfo: AlertInfo {
        switch self {
        case .delete:
            .init(
                icon: .icWarning,
                title: """
                내 정보를 초기화할까요?
                저장된 기록이 모두 삭제돼요.
                """,
                primaryButtonTitle: "삭제하기",
                secondaryButtonTitle: "닫기"
            )
        }
    }
}
