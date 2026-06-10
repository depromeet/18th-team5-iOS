//
//  RecordPhotoAreaView.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Camera
import ComposableArchitecture
import DesignSystem
import Domain
import PhotosUI
import SwiftUI

struct RecordPhotoView: View {
    @Bindable var store: StoreOf<RecordPhotoFeature>
    let subtitle: String?

    init(
        store: StoreOf<RecordPhotoFeature>,
        subtitle: String? = nil
    ) {
        self.store = store
        self.subtitle = subtitle
    }

    var body: some View {
        photoArea
            .fullScreenCover(
                item: $store.scope(state: \.camera, action: \.camera)
            ) { cameraStore in
                CameraView(store: cameraStore)
            }
            .sheet(
                item: $store.scope(state: \.photoPicker, action: \.photoPicker)
            ) { pickerStore in
                PhotoPickerView(store: pickerStore)
                    .presentationDetents([.fraction(0.9)])
                    .presentationDragIndicator(.hidden)
            }
            .customAlert(
                isPresented: store.alert != nil,
                icon: alertIcon,
                message: alertMessage,
                buttons: alertButtons,
                onAlertButtonTapped: { buttonID in
                    switch buttonID {
                    case "permission_ok":
                        store.send(.alertOpenSettingsTapped)
                    default:
                        store.send(.alertCancelTapped)
                    }
                }
            )
            .onChange(of: store.limitedPickerPresentationRequestID) { _, requestID in
                guard requestID != nil else { return }
                presentLimitedLibraryPicker()
                store.send(.limitedPickerFinished)
            }
    }
}

private extension RecordPhotoView {
    var photoArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .radius16)
                .fill(Color.gray800)

            if let imageData = store.selectedImageData,
               let uiImage = UIImage(data: imageData) {
                Color.clear
                    .overlay {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(.rect(cornerRadius: .radius16))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            store.send(.imageDeleteButtonTapped)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.monoWhite)
                                .frame(width: 32, height: 32)
                                .background(Color.gray700)
                                .clipShape(Circle())
                        }
                        .padding(12)
                        .accessibilityLabel("사진 삭제")
                    }
            } else {
                photoPlaceholder
            }
        }
        .frame(height: UIScreen.width - 40)
    }

    var photoPlaceholder: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("사진으로 기록을 남겨주세요")
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray400)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption1Regular)
                        .foregroundStyle(Color.gray500)
                }
            }

            HStack(spacing: 30) {
                cameraButton
                galleryButton
            }
        }
    }

    var cameraButton: some View {
        Button {
            store.send(.cameraButtonTapped)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.whiteAlpha600)
                    .frame(width: 56, height: 56)

                Image(systemName: "camera")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.gray800)
            }
        }
    }

    var galleryButton: some View {
        Button {
            store.send(.galleryButtonTapped)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.whiteAlpha600)
                    .frame(width: 56, height: 56)

                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.gray800)
            }
        }
    }
}

private extension RecordPhotoView {
    var alertIcon: Image? {
        switch store.alert {
        case .permissionDenied(.camera): .icCamera
        case .permissionDenied(.photoLibrary): .icPhoto
        case .none: nil
        }
    }

    var alertMessage: String {
        switch store.alert {
        case .permissionDenied(.camera):
            "기록 사진을 찍기 위해서\n카메라 접근 권한이 필요해요."
        case .permissionDenied(.photoLibrary):
            "기록 사진을 남기기 위해서\n사진 접근 권한이 필요해요."
        case .none:
            ""
        }
    }

    var alertButtons: [CustomAlertButton<String>] {
        switch store.alert {
        case .permissionDenied:
            return [
                CustomAlertButton(id: "permission_cancel", title: "취소", style: .secondary),
                CustomAlertButton(id: "permission_ok", title: "확인", style: .primary)
            ]
        case .none:
            return []
        }
    }
}

private extension RecordPhotoView {
    func presentLimitedLibraryPicker() {
        guard let rootVC = Self.topViewController() else { return }
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: rootVC)
    }

    static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let keyWindow = scenes.flatMap(\.windows).first(where: \.isKeyWindow)
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
