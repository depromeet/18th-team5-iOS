//
//  MissionRecordView.swift
//  Presentation
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
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
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
                .scrollDismissesKeyboard(.interactively)

                Spacer()

                submitButton
            }
            .background(background)
            .contentShape(.rect)
            .onTapGesture { isMemoFocused = false }
        }
        .loading(isLoading: store.isSubmitting)
        .navigationBarBackButtonHidden(true)
        .customAlert(
            isPresented: store.alert != nil,
            icon: nil,
            message: alertMessage,
            buttons: alertButtons,
            onAlertButtonTapped: { _ in
                store.send(.alertCancelTapped)
            }
        )
        .presentToast($store.toast)
        .onAppear {
            store.send(.onAppear)
        }
    }

    var background: some View {
        LinearGradient.missionRecordBackground
            .ignoresSafeArea()
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
        VStack(alignment: .leading, spacing: 2) {
            Text(store.missionTitle)
                .font(.body1Semibold)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let description = store.missionDescription {
                Text(description)
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray700)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.monoWhite)
        .clipShape(.rect(cornerRadius: .radius16))
    }
}

// MARK: - Photo Area

private extension MissionRecordView {
    var photoArea: some View {
        RecordPhotoView(
            store: store.scope(state: \.photo, action: \.photo)
        )
    }
}

// MARK: - Memo Section

private extension MissionRecordView {
    var memoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("한줄 메모 남기기")
                .font(.body1Semibold)
                .foregroundStyle(Color.gray800)

            memoInputField

            if store.isMemoLimitExceeded {
                Text("\(MissionRecordFeature.maxMemoLength)자까지 메모할 수 있어요.")
                    .font(.caption1Regular)
                    .foregroundStyle(Color.systemRed)
            }
        }
    }

    var memoInputField: some View {
        TextField("", text: $store.memo, axis: .vertical)
            .font(.body2Regular)
            .foregroundStyle(Color.gray900)
            .focused($isMemoFocused)
            .overlay(alignment: .leading) {
                if store.memo.isEmpty {
                    Text("함께 남기고 싶은 메모를 입력해주세요")
                        .font(.body2Regular)
                        .foregroundStyle(Color.gray500)
                        .allowsHitTesting(false)
                }
            }
            .padding(EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 16))
            .background(Color.monoWhite)
            .clipShape(.rect(cornerRadius: .radius16))
    }
}

// MARK: - Submit Button

private extension MissionRecordView {
    var isSubmitEnabled: Bool {
        store.photo.selectedImageData != nil && !store.isSubmitting
            && !store.memo.trimmingCharacters(in: .whitespaces).isEmpty
            && !store.isMemoLimitExceeded
    }

    var submitButton: some View {
        BottomButton(title: "확인") {
            store.send(.submitButtonTapped)
        }
        .disabled(!isSubmitEnabled)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Custom Alert Mapping

private extension MissionRecordView {
    var alertMessage: String {
        switch store.alert {
        case .submitFailed:
            "기록 저장에 실패했어요.\n잠시 후 다시 시도해주세요."
        case .none:
            ""
        }
    }

    var alertButtons: [CustomAlertButton<String>] {
        switch store.alert {
        case .submitFailed:
            return [
                CustomAlertButton(id: "submit_failure_cancel", title: "확인", style: .primary)
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
                missionType: .daily
            )
        ) {
            MissionRecordFeature()
        }
    )
}
