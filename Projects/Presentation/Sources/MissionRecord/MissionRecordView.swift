//
//  MissionRecordView.swift
//  Presentation
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import PhotosUI
import SwiftUI

public struct MissionRecordView: View {
    @Bindable private var store: StoreOf<MissionRecordFeature>
    @FocusState private var isMemoFocused: Bool
    @State private var photosPickerItem: PhotosPickerItem?

    public init(store: StoreOf<MissionRecordFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                navigationBar

                ScrollView {
                    VStack(spacing: 24) {
                        missionTitleCard
                        photoArea
                        memoSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
                .scrollDismissesKeyboard(.interactively)

                Spacer()

                submitButton
            }
            .background(Color.gray50)

            if store.showCompletionModal {
                completionModal
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(
            item: $store.scope(state: \.camera, action: \.camera)
        ) { cameraStore in
            CameraView(store: cameraStore)
        }
    }
}

// MARK: - Navigation Bar

private extension MissionRecordView {
    var navigationBar: some View {
        ZStack {
            Text("미션 기록하기")
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)

            HStack {
                backButton
                Spacer()
            }
            .padding(.leading, 20)
        }
        .frame(height: 56)
    }

    var backButton: some View {
        Button {
            store.send(.backButtonTapped)
        } label: {
            Image.icArrowLeft
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

// MARK: - Mission Title Card

private extension MissionRecordView {
    var missionTitleCard: some View {
        Text(store.missionTitle)
            .font(.body1Semibold)
            .foregroundStyle(Color.gray900)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(Color.gray200)
            .clipShape(.rect(cornerRadius: .radius16))
    }
}

// MARK: - Photo Area

private extension MissionRecordView {
    var photoArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .radius16)
                .fill(Color.gray800)

            if let imageData = store.selectedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(.rect(cornerRadius: .radius16))
            } else {
                photoPlaceholder
            }
        }
        .frame(height: UIScreen.width - 40)
    }

    var photoPlaceholder: some View {
        VStack(spacing: 20) {
            Text("사진으로 미션을 기록해주세요")
                .font(.body2Regular)
                .foregroundStyle(Color.gray400)

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
        PhotosPicker(
            selection: $photosPickerItem,
            matching: .images
        ) {
            ZStack {
                Circle()
                    .fill(Color.whiteAlpha600)
                    .frame(width: 56, height: 56)

                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.gray800)
            }
        }
        .onChange(of: photosPickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                let data = try? await newItem.loadTransferable(type: Data.self)
                store.send(.imageSelected(data))
            }
        }
    }
}

// MARK: - Memo Section

private extension MissionRecordView {
    var memoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("한줄 메모 남기기")
                .font(.body1Semibold)
                .foregroundStyle(Color.gray800)

            TextField("함께 남기고 싶은 메모를 입력해주세요", text: $store.memo)
                .font(.body2Regular)
                .foregroundStyle(Color.gray600)
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(Color.monoWhite)
                .clipShape(RoundedRectangle(cornerRadius: .radius16))
                .focused($isMemoFocused)
        }
    }
}

// MARK: - Submit Button

private extension MissionRecordView {
    var isSubmitEnabled: Bool {
        store.selectedImageData != nil && !store.isSubmitting
    }

    var submitButton: some View {
        Button {
            store.send(.submitButtonTapped)
        } label: {
            Text("기록 완료하기")
                .font(.body1Medium)
                .foregroundStyle(Color.monoWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isSubmitEnabled ? Color.gray900 : Color.gray400)
                .clipShape(RoundedRectangle(cornerRadius: .radius12))
        }
        .disabled(!isSubmitEnabled)
        .padding(.horizontal, 20)
        .padding(.bottom, 36)
    }
}

// MARK: - Completion Modal

private extension MissionRecordView {
    var completionModal: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {}

            VStack(spacing: 24) {
                Text("기록이 저장되었어요")
                    .font(.body1Semibold)
                    .foregroundStyle(Color.gray900)

                Button {
                    store.send(.completionModalConfirmTapped)
                } label: {
                    Text("확인")
                        .font(.body1Medium)
                        .foregroundStyle(Color.monoWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray900)
                        .clipShape(RoundedRectangle(cornerRadius: .radius12))
                }
            }
            .padding(24)
            .background(Color.monoWhite)
            .clipShape(RoundedRectangle(cornerRadius: .radius16))
            .padding(.horizontal, 40)
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: store.showCompletionModal)
    }
}

#Preview {
    MissionRecordView(
        store: .init(
            initialState: .init(missionTitle: "나만의 여름 음료 개발")
        ) {
            MissionRecordFeature()
        }
    )
}
