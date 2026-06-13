//
//  DevModeView.swift
//  Presentation
//
//  Created by 이정원 on 6/13/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct DevModeView: View {
    private let store: StoreOf<DevModeFeature>

    public init(store: StoreOf<DevModeFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                itemListView
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .navigationBar(
            title: "개발자 모드",
            dismissType: .close,
            action: { store.send(.closeButtonTapped) }
        )
        .background(Color.gray100)
    }
}

private extension DevModeView {
    var itemListView: some View {
        VStack(spacing: 0) {
            itemView(title: "User ID", content: store.userID ?? "")
        }
        .padding(.horizontal, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: .radius12))
    }

    func itemView(title: String, content: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(content)
                .font(.body2Regular)
                .foregroundStyle(Color.gray600)
        }
        .padding(.vertical, 18)
    }
}
