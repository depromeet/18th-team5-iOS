//
//  FreeRecordDateSelectionSheet.swift
//  Presentation
//
//  Created by 진준호 on 6/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct FreeRecordDateSelectionSheet: View {
    @Binding var selectedDate: Date

    let confirmedDate: Date
    let onClose: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            indicator
            header

            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .frame(height: 144)
            .clipped()

            BottomButton(title: "확인") {
                onConfirm()
            }
            .disabled(!isConfirmEnabled)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.monoWhite)
    }
}

private extension FreeRecordDateSelectionSheet {
    var indicator: some View {
        Capsule()
            .frame(width: 36, height: 5)
            .foregroundStyle(Color.gray200)
            .padding(.vertical, 6)
    }

    var header: some View {
        ZStack {
            Text("날짜 변경하기")
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)

            HStack {
                Button(action: onClose) {
                    Image.icClose
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.monoWhite)
                        .padding(12)
                        .background(Color.blackAlpha600)
                        .clipShape(Circle())
                }

                Spacer()
            }
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 16, trailing: 20))
    }

    var isConfirmEnabled: Bool {
        !Calendar.current.isDate(selectedDate, inSameDayAs: confirmedDate)
    }
}

#Preview {
    FreeRecordDateSelectionSheet(
        selectedDate: .constant(Date()),
        confirmedDate: Date(),
        onClose: {},
        onConfirm: {}
    )
}
