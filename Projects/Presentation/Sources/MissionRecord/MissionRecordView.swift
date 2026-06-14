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
        VStack(spacing: 0) {
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
        .contentShape(.rect)
        .onTapGesture { isMemoFocused = false }
        .navigationBar(title: "미션 기록하기") {
            store.send(.backButtonTapped)
        }
        .background(background)
        .loading(isLoading: store.isSubmitting)
        .customAlert(
            isPresented: store.alert != nil,
            icon: nil,
            message: alertMessage,
            buttons: alertButtons,
            onAlertButtonTapped: { _ in
                store.send(.alertCancelTapped)
            }
        )
        .customAlert(
            isPresented: store.photo.alert != nil,
            icon: store.photo.alert?.customAlertIcon,
            message: store.photo.alert?.customAlertMessage ?? "",
            buttons: store.photo.alert?.customAlertButtons ?? [],
            onAlertButtonTapped: { buttonID in
                switch buttonID {
                case "permission_ok":
                    store.send(.photo(.alertOpenSettingsTapped))
                default:
                    store.send(.photo(.alertCancelTapped))
                }
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
        RecordMemoSection(
            memo: $store.memo,
            isMemoFocused: $isMemoFocused,
            isLimitExceeded: store.isMemoLimitExceeded,
            maxMemoLength: MissionRecordFeature.maxMemoLength
        )
    }
}

// MARK: - Submit Button

private extension MissionRecordView {
    var isSubmitEnabled: Bool {
        store.hasRecordImage
            && !store.isSubmitting
            && !store.isMemoLimitExceeded
            && (!store.isEditing || store.hasEditedContent)
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
