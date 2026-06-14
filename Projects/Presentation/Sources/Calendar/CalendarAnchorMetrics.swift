//
//  CalendarAnchorMetrics.swift
//  Presentation
//
//  Created by choijunios on 6/14/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// 캘린더 날짜 셀의 스크롤 anchor inset 계산.
/// 셀 탭(View)과 외부 진입(`openDetail`, Feature)이 동일한 inset을 쓰도록 공유한다.
enum CalendarAnchorMetrics {
    static let termSectionHeaderHeight: CGFloat = 56
    static let weekSectionVerticalSpacing: CGFloat = 4
    static let cellHeight: CGFloat = 90

    /// 절기 섹션 상단으로부터 `weekIndex` 주(week) 셀까지의 Y 오프셋.
    static func dateCellAnchorInset(weekIndex: Int) -> CGFloat {
        let weekStartY = (cellHeight + weekSectionVerticalSpacing) * CGFloat(weekIndex)
        return termSectionHeaderHeight + weekStartY
    }
}
