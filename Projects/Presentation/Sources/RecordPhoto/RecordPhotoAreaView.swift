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
import Kingfisher
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
                selectedImageView(uiImage)
            } else if let existingImageURL = store.existingImageURL {
                existingImageView(existingImageURL)
            } else {
                photoPlaceholder
            }
        }
        .frame(height: UIScreen.width - 40)
    }

    func selectedImageView(_ image: UIImage) -> some View {
        imageContainer {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        }
    }

    func existingImageView(_ url: URL) -> some View {
        imageContainer {
            KFImage(url)
                .placeholder {
                    Color.gray100
                }
                .fade(duration: 0.25)
                .resizable()
                .scaledToFill()
        }
    }

    func imageContainer(@ViewBuilder content: () -> some View) -> some View {
        Color.clear
            .overlay {
                content()
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
                        .clipShape(.circle)
                }
                .padding(12)
                .accessibilityLabel("사진 삭제")
            }
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

            HStack(spacing: 24) {
                cameraButton
                galleryButton
            }
        }
    }

    var cameraButton: some View {
        Button {
            store.send(.cameraButtonTapped)
        } label: {
            Image.icCamera
                .resizable()
                .frame(width: 20, height: 20)
                .padding(12)
                .background(Color.whiteAlpha600)
                .clipShape(.circle)
        }
    }

    var galleryButton: some View {
        Button {
            store.send(.galleryButtonTapped)
        } label: {
            Image.icPhoto
                .resizable()
                .frame(width: 20, height: 20)
                .padding(12)
                .background(Color.whiteAlpha600)
                .clipShape(.circle)
        }
    }
}

private extension RecordPhotoView {
    var alertIcon: Image? {
        switch store.alert {
        case .permissionDenied(.camera): .ic2dCamera
        case .permissionDenied(.photoLibrary): .ic2dPhoto
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
