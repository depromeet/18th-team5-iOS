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

    public init(store: StoreOf<FreeRecordFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                navigationBar

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
    }

    var background: some View {
        LinearGradient.missionRecordBackground
            .ignoresSafeArea()
    }
}

// MARK: - Navigation Bar

private extension FreeRecordView {
    var navigationBar: some View {
        ZStack {
            Text("기록하기")
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
        .overlay {
            DatePicker(
                "",
                selection: $store.recordDate,
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .opacity(0.02)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
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
        VStack(alignment: .leading, spacing: 12) {
            Text("한줄 메모 남기기")
                .font(.body1Semibold)
                .foregroundStyle(Color.gray800)

            memoInputField

            if store.isMemoLimitExceeded {
                Text("\(FreeRecordFeature.maxMemoLength)자까지 메모할 수 있어요.")
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

private extension FreeRecordView {
    var isSubmitEnabled: Bool {
        store.photo.selectedImageData != nil
            && !store.isSubmitting
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
