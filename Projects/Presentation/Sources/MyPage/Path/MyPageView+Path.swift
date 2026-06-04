//
//  MyPageView+Path.swift
//  Presentation
//
//  Created by 이정원 on 6/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

extension MyPageView {
    @ViewBuilder
    func pathView(_ store: StoreOf<MyPageFeature.Path>) -> some View {
        switch store.case {
        case let .notificationSettings(store): NotificationSettingsView(store: store)
        }
    }
}
