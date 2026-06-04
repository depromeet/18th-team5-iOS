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
    @Bindable private var store: StoreOf<MyPageFeature>

    public init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            navigationBar
            ScrollView {
                VStack(spacing: 16) {
                    MenuListView { menu in
                        store.send(.menuTapped(menu))
                    }

                    versionInfoView
                    deleteButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .background { backgroundView }
        .navigationBarBackButtonHidden()
        .navigationDestination(
            item: $store.scope(state: \.path, action: \.path),
            destination: pathView
        )
    }
}

private extension MyPageView {
    var navigationBar: some View {
        ZStack {
            Text("마이페이지")
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity)

            HStack(spacing: 0) {
                backButton
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 56)
    }

    var backButton: some View {
        Button {
            store.send(.backButtonTapped)
        } label: {
            Image.icArrowLeft
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.gray800)
        }
    }

    var versionInfoView: some View {
        HStack(spacing: 12) {
            Text("버전")
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(store.version)
                .font(.body2Regular)
                .foregroundStyle(Color.gray600)

            Button {
                store.send(.updateButtonTapped)
            } label: {
                Text("업데이트")
                    .font(.body2Medium)
                    .foregroundStyle(Color.gray50)
                    .padding(.horizontal, 12)
                    .frame(height: 32)
                    .background(Color.gray700)
                    .clipShape(RoundedRectangle(cornerRadius: .radius8))
            }
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
