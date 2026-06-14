//
//  CalendarDetailView+Card.swift
//  Presentation
//
//  Created by choijunios on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import SwiftUI

extension CalendarDetailView {
    var cardWidth: CGFloat {
        max(screenSize.width - RecordCardLayout.cardHorizontalPadding * 2, 0)
    }

    func cardView(
        term: SolarTerm,
        cardIndex: Int,
        orderIndex: Int,
        card: DateRecordCard,
        totalCount: Int
    ) -> some View {
        Group {
            if orderIndex == 0 {
                // 내용 카드는 Equatable 뷰로 분리하여 드래그 중 본문 재빌드를 방지합니다.
                RecordCardContentView(
                    term: term,
                    card: card,
                    cardIndex: cardIndex,
                    totalCount: totalCount,
                    cardWidth: cardWidth,
                    onDeleteTapped: {
                        store.send(.removeCardButtonTapped)
                    },
                    onEditTapped: {
                        store.send(.editRecordButtonTapped)
                    }
                )
                .equatable()
            } else {
                RoundedRectangle(cornerRadius: RecordCardLayout.cardCornerRadius)
                    .foregroundStyle(
                        orderIndex <= 1 ? Color.gray200 : Color.gray50
                    )
            }
        }
        .frame(
            width: cardWidth,
            height: cardWidth * RecordCardLayout.cardRatio
        )
    }
}
