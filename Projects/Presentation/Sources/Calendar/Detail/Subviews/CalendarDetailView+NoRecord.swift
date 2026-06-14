//
//  CalendarDetailView+NoRecord.swift
//  Presentation
//
//  Created by choijunios on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

extension CalendarDetailView {
    func currentTermNoRecordView(
        onRecordButtonTapped: @escaping () -> Void
    ) -> some View {
        ZStack {
            VStack {
                VStack(spacing: 8) {
                    Text("아직 제철 기록이 채워지지 않았어요\n비어 있는 하루를 기록해볼까요?")
                        .multilineTextAlignment(.center)
                        .font(.headline2Medium)
                        .foregroundStyle(Color.gray900)

                    Image.calendarNoRecordCurrentTermImage
                        .resizable()
                        .scaledToFit()
                }
                .padding(.horizontal, 27.5)
                .padding(.top, 80)

                Spacer()
            }

            VStack {
                Spacer()

                Button {
                    onRecordButtonTapped()
                } label: {
                    Text("기록하기")
                }
                .buttonStyle(.master(.large))
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
    }

    var passedTermNoRecordView: some View {
        VStack {
            VStack(spacing: 8) {
                Text("기록 없이 지나간 날이에요\n다가온 절기에서 기록을 남겨보세요")
                    .multilineTextAlignment(.center)
                    .font(.headline2Medium)
                    .foregroundStyle(Color.gray900)

                Image.calendarNoRecordPassedTermImage
                    .resizable()
                    .scaledToFit()
            }
            .padding(.horizontal, 27.5)
            .padding(.top, 80)

            Spacer()
        }
    }

    var futureTermRecordView: some View {
        VStack {
            VStack(spacing: 8) {
                Text("아직 찾아오지 않은 절기예요\n다가오는 절기에서 만나요")
                    .multilineTextAlignment(.center)
                    .font(.headline2Medium)
                    .foregroundStyle(Color.gray900)

                Image.calendarFutureTermImage
                    .resizable()
                    .scaledToFit()
            }
            .padding(.horizontal, 27.5)
            .padding(.top, 80)

            Spacer()
        }
    }
}

#Preview {
    CalendarDetailView(
        store: .init(initialState: .init(date: .now)) {
            CalendarDetailFeature()
        }
    )
    .currentTermNoRecordView(onRecordButtonTapped: {})
}

#Preview {
    CalendarDetailView(
        store: .init(initialState: .init(date: .now)) {
            CalendarDetailFeature()
        }
    )
    .passedTermNoRecordView
}
