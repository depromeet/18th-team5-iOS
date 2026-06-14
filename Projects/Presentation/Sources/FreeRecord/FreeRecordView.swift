//
//  FreeRecordView.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct FreeRecordView: View {
    @Bindable private var store: StoreOf<FreeRecordFeature>
    @FocusState private var isMemoFocused: Bool
    @State private var isDateSelectionSheetPresented = false
    @State private var draftRecordDate = Date()

    public init(store: StoreOf<FreeRecordFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    dateSection
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
        .navigationBar(title: "기록하기") {
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
        .presentToast($store.toast)
        .task {
            await store.send(.task).finish()
        }
        .sheet(isPresented: $isDateSelectionSheetPresented) {
            FreeRecordDateSelectionSheet(
                selectedDate: $draftRecordDate,
                confirmedDate: store.recordDate,
                selectableDateRange: store.selectableDateRange,
                onClose: {
                    isDateSelectionSheetPresented = false
                },
                onConfirm: {
                    store.recordDate = draftRecordDate
                    isDateSelectionSheetPresented = false
                }
            )
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.hidden)
        }
    }

    var background: some View {
        LinearGradient.missionRecordBackground
            .ignoresSafeArea()
    }
}

// MARK: - Date Section

private extension FreeRecordView {
    var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("날짜 선택하기")
                .font(.body1Semibold)
                .foregroundStyle(Color.gray800)

            datePickerField
        }
    }

    var datePickerField: some View {
        Button {
            isMemoFocused = false
            draftRecordDate = store.recordDate
            isDateSelectionSheetPresented = true
        } label: {
            HStack {
                Text(Self.displayDateFormatter.string(from: store.recordDate))
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray900)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray500)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.monoWhite)
            .clipShape(.rect(cornerRadius: .radius16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Photo Area

private extension FreeRecordView {
    var photoArea: some View {
        RecordPhotoView(
            store: store.scope(state: \.photo, action: \.photo),
            subtitle: "하루 1개의 사진을 자유롭게 기록할 수 있어요"
        )
    }
}

// MARK: - Memo Section

private extension FreeRecordView {
    var memoSection: some View {
        RecordMemoSection(
            memo: $store.memo,
            isMemoFocused: $isMemoFocused,
            isLimitExceeded: store.isMemoLimitExceeded,
            maxMemoLength: FreeRecordFeature.maxMemoLength
        )
    }
}

// MARK: - Submit Button

private extension FreeRecordView {
    var isSubmitEnabled: Bool {
        store.photo.selectedImageData != nil
            && !store.isSubmitting
            && !store.memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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

private extension FreeRecordView {
    var alertMessage: String {
        switch store.alert {
        case .submitFailed:
            "기록 저장에 실패했어요.\n잠시 후 다시 시도해주세요."
        case .freeRecordLimitExceeded:
            "선택한 날짜의 기록을 이미 채웠어요\n다른 날의 제철 일상을 남겨볼까요?"
        case .none:
            ""
        }
    }

    var alertButtons: [CustomAlertButton<String>] {
        switch store.alert {
        case .submitFailed, .freeRecordLimitExceeded:
            return [
                CustomAlertButton(id: "submit_failure_cancel", title: "확인", style: .primary)
            ]
        case .none:
            return []
        }
    }

    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

#Preview {
    FreeRecordView(
        store: .init(initialState: .init(recordDate: Date())) {
            FreeRecordFeature()
        }
    )
}
