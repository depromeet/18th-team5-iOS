//
//  CalendarView2.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

struct CalendarView2: View {
    @Bindable var store: StoreOf<CalendarFeature2>

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                headerView

                PagingTableView(
                    groups: store.yearPages,
                    centerItemId: $store.centerItemId,
                    onPagingRequest: {
                        store.send(.calendarPagingRequest($0))
                    },
                    cellHeight: { _ in
                        500
                    },
                    cellContent: {
                        termView($0, containerWidth: geo.size.width)
                            .frame(height: 500)
                    }
                )
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

extension CalendarView2 {
    func termView(_ termGroup: SolarTermGroup, containerWidth: CGFloat) -> some View {
        let cellWidth = (containerWidth - 3 * 6) / 7
        return VStack(alignment: .leading, spacing: 3) {
            ForEach(termGroup.cells.indices, id: \.self) {
                let week = termGroup.cells[$0]
                HStack(spacing: 3) {
                    ForEach(week) { day in
                        switch day {
                        case .emptyCell:
                            Rectangle()
                                .stroke(.black)
                                .background(Color.white)
                                .frame(width: cellWidth, height: 56)

                        case let .dateCell(info):
                            Rectangle()
                                .stroke(.red)
                                .background(Color.white)
                                .frame(width: cellWidth, height: 56)
                                .overlay {
                                    Text(info.dayText)
                                }
                        }
                    }
                }
            }
        }
    }

    var headerView: some View {
        VStack {
            HStack(alignment: .center, spacing: 8) {
                Text(store.header.termTitleText)
                    .font(.title2Semibold)
                    .foregroundStyle(Color.gray900)

                Text(store.header.termRangeText)
                    .font(.caption1Medium)
                    .foregroundStyle(Color.gray400)

                Spacer()
            }
            WeekdayLabelRow()
        }
    }
}
