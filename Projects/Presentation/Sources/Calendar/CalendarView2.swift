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
    let store: StoreOf<CalendarFeature2>

    var body: some View {
        VStack(spacing: 0) {
            headerView

            GeometryReader { geo in
                let cellWidth = (geo.size.width - 3 * 6) / 7

                ScrollView {
                    ForEach(store.solarTermGroups) {
                        termView($0, cellWidth: cellWidth)
                    }
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

extension CalendarView2 {
    func termView(_ termGroup: SolarTermGroup, cellWidth: CGFloat) -> some View {
        LazyVStack(alignment: .leading, spacing: 3) {
            let weekChunks = termGroup.cells.chunked(size: 7)
            ForEach(weekChunks.indices, id: \.self) {
                let week = weekChunks[$0]
                HStack(spacing: 3) {
                    ForEach(week) { day in
                        switch day {
                        case .emptyCell:
                            Rectangle()
                                .stroke(.black)
                                .frame(width: cellWidth, height: 56)

                        case let .dateCell(info):
                            Rectangle()
                                .stroke(.red)
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

extension Array {
    func chunked(size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
