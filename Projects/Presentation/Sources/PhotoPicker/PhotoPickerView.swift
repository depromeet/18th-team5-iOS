//
//  PhotoPickerView.swift
//  Presentation
//
//  Created by 진준호 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct PhotoPickerView: View {
    private let store: StoreOf<PhotoPickerFeature>

    public init(store: StoreOf<PhotoPickerFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            header

            if store.isLimited {
                limitedBanner
            }

            grid
        }
        .background(Color.gray50)
        .loading(isLoading: store.isLoading)
        .onAppear { store.send(.onAppear) }
        .customAlert(
            isPresented: store.alert != nil,
            message: alertMessage,
            buttons: alertButtons
        )
        .interactiveDismissDisabled(true)
    }
}

// MARK: - Custom Alert Mapping

private extension PhotoPickerView {
    var alertMessage: String {
        switch store.alert {
        case .imageLoadFailed:
            "사진을 불러오지 못했어요.\n다른 사진을 선택해주세요."
        case .none:
            ""
        }
    }

    var alertButtons: [CustomAlertButton] {
        switch store.alert {
        case .imageLoadFailed:
            return [
                CustomAlertButton(title: "확인", style: .primary) {
                    store.send(.alertConfirmTapped)
                }
            ]
        case .none:
            return []
        }
    }
}

// MARK: - Header

private extension PhotoPickerView {
    var header: some View {
        HStack {
            closeButton
            Spacer()
            Text("사진")
                .font(.body1Semibold)
                .foregroundStyle(Color.gray900)
            Spacer()
            confirmButton
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 18, trailing: 16))
    }

    var closeButton: some View {
        Button {
            store.send(.closeTapped)
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.monoWhite)
                .frame(width: 44, height: 44)
                .background(Color.gray400)
                .clipShape(.circle)
        }
        .accessibilityLabel("닫기")
    }

    var confirmButton: some View {
        let isEnabled = store.selectedAssetId != nil
        return Button {
            store.send(.confirmTapped)
        } label: {
            Image(systemName: "arrow.up")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.monoWhite)
                .frame(width: 44, height: 44)
                .background(isEnabled ? Color.gray700 : Color.gray400)
                .clipShape(.circle)
        }
        .disabled(!isEnabled)
        .accessibilityLabel("선택 완료")
    }
}

// MARK: - Limited Banner

private extension PhotoPickerView {
    var limitedBanner: some View {
        Button {
            store.send(.manageLimitedTapped)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 14, weight: .semibold))
                Text("사진 더 선택하기")
                    .font(.body2Medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(Color.gray700)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray200)
        }
    }
}

// MARK: - Grid

private extension PhotoPickerView {
    var grid: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 2
            let columnCount: CGFloat = 3
            let cellSide = (geometry.size.width - spacing * (columnCount - 1)) / columnCount
            let columns = Array(
                repeating: GridItem(.fixed(cellSide), spacing: spacing),
                count: Int(columnCount)
            )

            ScrollView {
                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(store.assets) { asset in
                        PhotoThumbnailCell(
                            assetId: asset.id,
                            side: cellSide,
                            isSelected: store.selectedAssetId == asset.id
                        ) {
                            store.send(.photoTapped(asset.id))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - PhotoThumbnailCell

struct PhotoThumbnailCell: View {
    let assetId: String
    let side: CGFloat
    let isSelected: Bool
    let onTap: () -> Void

    @Dependency(\.photoLibraryClient) private var photoLibraryClient
    @State private var image: UIImage?

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Color.gray200

                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: side, height: side)
                        .clipped()
                }

                if isSelected {
                    Color.black.opacity(0.3)

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            checkmark
                                .padding(6)
                        }
                    }
                }
            }
            .frame(width: side, height: side)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .task(id: assetId) {
            let scale = UIScreen.main.scale
            let targetSize = CGSize(width: side * scale, height: side * scale)
            image = await loadImage(size: targetSize)
        }
    }

    private var checkmark: some View {
        ZStack {
            Circle()
                .fill(Color.gray800)
                .frame(width: 22, height: 22)
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.monoWhite)
        }
    }

    private func loadImage(size: CGSize) async -> UIImage? {
        guard let data = await photoLibraryClient.loadThumbnail(assetId, size) else { return nil }
        return UIImage(data: data)
    }
}
