//
//  MissionRecordView.swift
//  Presentation
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct MissionRecordView: View {
    @Bindable private var store: StoreOf<MissionRecordFeature>
    @FocusState private var isMemoFocused: Bool

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
            .contentShape(.rect)
            .onTapGesture { isMemoFocused = false }
            .allowsHitTesting(store.completionModal == nil)
            .accessibilityHidden(store.completionModal != nil)

            if store.completionModal != nil {
                completionModal
            }
        }
        .loading(isLoading: store.isSubmitting)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(
            item: $store.scope(state: \.camera, action: \.camera)
        ) { cameraStore in
            CameraView(store: cameraStore)
        }
        .sheet(
            item: $store.scope(state: \.photoPicker, action: \.photoPicker)
        ) { pickerStore in
            PhotoPickerView(store: pickerStore)
        }
        .customAlert(
            isPresented: store.alert != nil,
            icon: alertIcon,
            message: alertMessage,
            buttons: alertButtons
        )
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
            && !store.memo.trimmingCharacters(in: .whitespaces).isEmpty
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
                .background(isSubmitEnabled ? Color.gray700 : Color.gray400)
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
                    .font(.body1Medium)
                    .foregroundStyle(Color.gray900)

                Button {
                    store.send(.completionModal(.presented(.confirmTapped)))
                } label: {
                    Text("확인")
                        .font(.body1Medium)
                        .foregroundStyle(Color.monoWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray700)
                        .clipShape(.rect(cornerRadius: .radius12))
                }
            }
            .padding(24)
            .background(Color.monoWhite)
            .clipShape(.rect(cornerRadius: .radius12))
            .padding(.horizontal, 40)
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: store.completionModal != nil)
    }
}

// MARK: - Custom Alert Mapping

private extension MissionRecordView {
    var alertIcon: Image? {
        switch store.alert {
        case .permissionDenied(.camera): .icCamera
        case .permissionDenied(.photoLibrary): .icPhoto
        case .submitFailed, .none: nil
        }
    }

    var alertMessage: String {
        switch store.alert {
        case .permissionDenied(.camera):
            "미션 기록 사진을 찍기 위해서\n카메라 접근 권한이 필요해요."
        case .permissionDenied(.photoLibrary):
            "미션 기록 사진을 남기기 위해서\n사진 접근 권한이 필요해요."
        case .submitFailed:
            "기록 저장에 실패했어요.\n잠시 후 다시 시도해주세요."
        case .none:
            ""
        }
    }

    var alertButtons: [CustomAlertButton] {
        switch store.alert {
        case .permissionDenied:
            return [
                CustomAlertButton(title: "취소", style: .secondary) {
                    store.send(.alertCancelTapped)
                },
                CustomAlertButton(title: "확인", style: .primary) {
                    store.send(.alertOpenSettingsTapped)
                }
            ]
        case .submitFailed:
            return [
                CustomAlertButton(title: "확인", style: .primary) {
                    store.send(.alertCancelTapped)
                }
            ]
        case .none:
            return []
        }
    }
}

#Preview {
    MissionRecordView(
        store: .init(
            initialState: .init(
                missionId: 0,
                missionTitle: "나만의 여름 음료 개발",
                missionType: .daily,
                solarTermId: 0
            )
        ) {
            MissionRecordFeature()
        }
    )
}
