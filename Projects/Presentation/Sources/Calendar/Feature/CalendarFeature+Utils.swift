//
//  CalendarFeature+Utils.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

// MARK: - Utils

extension CalendarFeature {
    func findTermGroup(pages: [Page<SolarTermGroup>], dateId: SolarTermDate.ID) -> SolarTermGroup? {
        for yearPage in pages {
            for termGroup in yearPage.items {
                for cell in termGroup.cells.flatMap(\.self) {
                    if case let .dateCell(date) = cell, date.id == dateId {
                        return termGroup
                    }
                }
            }
        }
        return nil
    }

    func findTermGroup(pages: [Page<SolarTermGroup>], termId: SolarTermGroup.ID) -> SolarTermGroup? {
        for yearPage in pages {
            for termGroup in yearPage.items {
                if termGroup.id == termId { return termGroup }
            }
        }
        return nil
    }
}
