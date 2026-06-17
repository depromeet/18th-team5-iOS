//
//  RecordMemoSection.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct RecordMemoSection: View {
    @Binding private var memo: String
    private let isMemoFocused: FocusState<Bool>.Binding
    private let isLimitExceeded: Bool
    private let maxMemoLength: Int

    init(
        memo: Binding<String>,
        isMemoFocused: FocusState<Bool>.Binding,
        isLimitExceeded: Bool,
        maxMemoLength: Int
    ) {
        self._memo = memo
        self.isMemoFocused = isMemoFocused
        self.isLimitExceeded = isLimitExceeded
        self.maxMemoLength = maxMemoLength
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("한줄 메모 남기기")
                .font(.body1Semibold)
                .foregroundStyle(Color.gray800)

            memoInputField

            if isLimitExceeded {
                Text("\(maxMemoLength)자까지 메모할 수 있어요.")
                    .font(.caption1Regular)
                    .foregroundStyle(Color.systemRed)
            }
        }
    }
}

private extension RecordMemoSection {
    var memoInputField: some View {
        TextField("", text: $memo, axis: .vertical)
            .font(.body2Regular)
            .foregroundStyle(Color.gray900)
            .focused(isMemoFocused)
            .overlay(alignment: .leading) {
                if memo.isEmpty {
                    Text("함께 남기고 싶은 메모를 입력해주세요")
                        .font(.body2Regular)
                        .foregroundStyle(Color.gray500)
                        .allowsHitTesting(false)
                }
            }
            .tint(isMemoFocused.wrappedValue ? Color.green500 : Color.clear)
            .padding(EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 16))
            .background(Color.monoWhite)
            .clipShape(.rect(cornerRadius: .radius16))
            .overlay {
                if isMemoFocused.wrappedValue {
                    RoundedRectangle(cornerRadius: .radius16)
                        .strokeBorder(Color.blackAlpha200, lineWidth: 1)
                }
            }
            .onChange(of: memo) { _, newValue in
                guard newValue.contains(where: \.isNewline) else { return }
                memo = newValue.filter { !$0.isNewline }
            }
    }
}
