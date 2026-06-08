//
//  NewCustomAlertViewModifier.swift
//  Presentation
//
//  Created by 이정원 on 6/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public protocol AlertPresentable: Equatable {
    var alertInfo: AlertInfo { get }
}

struct NewCustomAlertViewModifier<Alert: AlertPresentable>: ViewModifier {
    private let store: StoreOf<CustomAlertFeature<Alert>>?

    init(store: StoreOf<CustomAlertFeature<Alert>>?) {
        self.store = store
    }

    func body(content: Content) -> some View {
        ZStack {
            content
                .allowsHitTesting(store == nil)

            if let store {
                let alert = store.alert

                Color.black.opacity(0.45)
                    .opacity(0.5)
                    .ignoresSafeArea()

                NewCustomAlertView(
                    alertInfo: alert.alertInfo,
                    primaryAction: {
                        store.send(.primaryButtonTapped(alert))
                    },
                    secondaryAction: {
                        store.send(.secondaryButtonTapped(alert))
                    }
                )
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.25), value: store == nil)
    }
}

public extension View {
    func customAlert(
        _ store: StoreOf<CustomAlertFeature<some AlertPresentable>>?
    ) -> some View {
        modifier(NewCustomAlertViewModifier(store: store))
    }
}
