//
//  CalendarDateCell.swift
//  Presentation
//
//  Created by choijunios on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Kingfisher
import SwiftUI

struct CalendarDateCell: View {
    enum Constants {
        static let cellHeight: CGFloat = 90
        static let thumbnailSize: CGFloat = 32
    }

    let date: SolarTermDate
    var data: CalendarDateRecord?
    let onTap: () -> Void

    var body: some View {
        ZStack {
            if date.isFirstDayOfMonth { monthView }

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(date.isSelected ? Color.green500 : Color.gray50)
                    .shadow(color: Color.green100, radius: date.isSelected ? 8 : 0)

                HStack(spacing: 0) {
                    Spacer(minLength: 5)

                    VStack(spacing: 6) {
                        thumbnailView
                        dateTextView
                    }
                    .padding(.vertical, 6)

                    Spacer(minLength: 5)
                }
            }
            .padding(.top, 20)
            .onTapGesture(perform: onTap)
        }
        .frame(height: Constants.cellHeight)
    }

    var monthView: some View {
        Color.gray200
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .top) {
                Text(date.monthText)
                    .font(.caption2Semibold)
                    .foregroundStyle(Color.gray700)
                    .padding(.top, 2)
            }
    }

    var thumbnailView: some View {
        Group {
            if let url = data?.thumbnailURL {
                KFImage(url)
                    .setProcessor(
                        DownsamplingImageProcessor(
                            size: CGSize(
                                width: Constants.thumbnailSize,
                                height: Constants.thumbnailSize
                            )
                        )
                    )
                    .placeholder { thumbnailPlaceHolder }
                    .scaleFactor(UIScreen.main.scale)
                    .fade(duration: 0.2)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                thumbnailPlaceHolder
            }
        }
        .frame(
            width: Constants.thumbnailSize,
            height: Constants.thumbnailSize
        )
        .clipShape(
            CalendarCellImageShape(
                containerPadding: 2.56,
                containerRadius: 4,
                protrusionRadius: 1.78
            )
        )
    }

    var dateTextView: some View {
        Text(date.dayText)
            .font(.body2Medium)
            .foregroundStyle(
                (date.isSelected || date.isToday) ? Color.white : Color.gray900
            )
            .frame(maxWidth: .infinity)
            .background {
                if date.isToday {
                    Capsule().fill(Color.green500)
                }
            }
    }

    var thumbnailPlaceHolder: some View {
        Rectangle()
            .foregroundStyle(Color.gray200)
    }
}

#Preview {
    func previewCell(
        _ title: String,
        isFirstDayOfMonth: Bool = false,
        isToday: Bool = false,
        isSelected: Bool = false
    ) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
            CalendarDateCell(
                date: .init(
                    id: title,
                    monthText: "12월",
                    dayText: "12",
                    isFirstDayOfMonth: isFirstDayOfMonth,
                    isToday: isToday,
                    isSelected: isSelected,
                    year: .current,
                    term: .ipchun,
                    month: 1,
                    day: 1
                ),
                onTap: {}
            )
            .frame(width: 42)
        }
    }

    return VStack(spacing: 20) {
        HStack(spacing: 16) {
            previewCell("일반일")
            previewCell("오늘", isToday: true)
            previewCell("선택됨", isSelected: true)
        }
        HStack(spacing: 16) {
            previewCell("오늘+선택됨", isToday: true, isSelected: true)
            previewCell("달의 첫날", isFirstDayOfMonth: true)
            previewCell("첫날+선택됨", isFirstDayOfMonth: true, isSelected: true)
        }
    }
    .padding()
}
