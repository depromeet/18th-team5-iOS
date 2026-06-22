//
//  TermSectionView.swift
//  Presentation
//
//  Created by choijunios on 6/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

struct TermSectionView: View {
    let termGroup: SolarTermGroup
    let dateCellWidth: CGFloat
    let records: [SolarTermDate.ID: CalendarDateRecord]
    let onDateTap: (SolarTermDate.ID, CGFloat) -> Void

    var body: some View {
        VStack(spacing: .zero) {
            termSectionHeaderView
            termCalendarView
        }
        .padding(.bottom, Constants.termSectionBottomPadding)
        .overlay {
            VStack {
                Spacer()
                Rectangle()
                    .foregroundStyle(Color.gray200)
                    .frame(height: 1)
            }
        }
    }

    private var termSectionHeaderView: some View {
        VStack {
            HStack {
                Text(termGroup.termText)
                    .font(.headline2Medium)
                    .foregroundStyle(
                        termGroup.containsToday ? Color.green600 : Color.gray900
                    )
                Spacer()
            }
            .padding(.top, 24)

            Spacer()
        }
        .frame(height: Constants.termSectionHeaderHeight)
    }

    private var termCalendarView: some View {
        VStack(alignment: .leading, spacing: Constants.weekSectionVerticalSpacing) {
            ForEach(termGroup.cells.indices, id: \.self) { weekIndex in
                HStack(spacing: Constants.dateCellHorizontalSpacing) {
                    ForEach(termGroup.cells[weekIndex]) { cell in
                        dateCellView(
                            cell: cell,
                            anchorInset: CalendarAnchorMetrics.dateCellAnchorInset(weekIndex: weekIndex)
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dateCellView(cell: SolarTermGroupCell, anchorInset: CGFloat) -> some View {
        switch cell {
        case .emptyCell:
            Color.clear
                .frame(width: dateCellWidth, height: 1)

        case let .dateCell(date):
            CalendarDateCell(
                date: date,
                data: records[date.id]
            ) {
                onDateTap(date.id, anchorInset)
            }
            .frame(width: dateCellWidth)
        }
    }
}

private enum Constants {
    static let termSectionHeaderHeight: CGFloat = CalendarAnchorMetrics.termSectionHeaderHeight
    static let termSectionBottomPadding: CGFloat = 12
    static let weekSectionVerticalSpacing: CGFloat = CalendarAnchorMetrics.weekSectionVerticalSpacing
    static let dateCellHorizontalSpacing: CGFloat = 7
}
