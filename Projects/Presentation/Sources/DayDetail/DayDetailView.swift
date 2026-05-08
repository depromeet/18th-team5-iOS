//  DayDetailView.swift
//  Presentation
//
//  Created by 송민교 on 5/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct DayDetailView: View {
    @Bindable var store: StoreOf<DayDetailFeature>

    public init(store: StoreOf<DayDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            miniCalendarSection // 상단 흰색 카드 - 한 주 미니 캘린더

            Divider()
                .foregroundStyle(Color.gray100)
                .padding(.bottom, 16)

            missionCardSection // 미션 카드 스택

            Spacer()

            actionButtons
                .padding(.horizontal, 17)
                .padding(.bottom, 16)
        }
        .background(Color.gray50)
        .onAppear { store.send(.onAppear) } // 화면 뜰 때 해당 날짜 미션 불러오기
    }

    // MARK: - Mini Calendar

    private var miniCalendarSection: some View {
        VStack(spacing: 12) {
            CalendarHeaderView(
                title: store.selectedDate.yearMonthString,
                onPrevious: { store.send(.previousWeekTap) },
                onNext: { store.send(.nextWeekTap) }
            )

            WeekdayLabelRow()

            HStack(spacing: 0) {
                ForEach(store.weekDays, id: \.self) { date in
                    let key = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    let record = store.weekRecords[key]
                    let isSelected = Calendar.current.isDate(store.selectedDate, inSameDayAs: date)

                    DayCell(
                        day: Calendar.current.component(.day, from: date),
                        imageURL: record?.imageURL,
                        isSelected: isSelected,
                        onTap: { store.send(.dateTap(date)) }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .background(Color.monoWhite)
    }

    // MARK: - Mission Card Stack

    private var missionCardSection: some View {
        Color.clear
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 13) {
            Button { store.send(.saveImageTap) } label: {
                Text("이미지 저장")
                    .font(.body1Medium)
                    .foregroundStyle(Color.gray50)
                    .frame(maxWidth: .infinity)
                    .frame(height: 47)
                    .background(Color.gray800)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Button { store.send(.saveLinkTap) } label: {
                Text("링크 저장")
                    .font(.body1Medium)
                    .foregroundStyle(Color.gray50)
                    .frame(maxWidth: .infinity)
                    .frame(height: 47)
                    .background(Color.gray800)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    DayDetailView(
        store: .init(initialState: .init(
            selectedDate: Date(),
            weekRecords: [DateComponents: CalendarRecord]()
        )) {
            DayDetailFeature()
        } withDependencies: {
            $0.calendarRepository = .mock
        }
    )
}
