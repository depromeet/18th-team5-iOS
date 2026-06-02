//
//  NotificationListView.swift
//  Presentation
//
//  Created by 이정원 on 6/2/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct NotificationListView: View {
    private let store: StoreOf<NotificationListFeature>

    public init(store: StoreOf<NotificationListFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("NOTIFICATION LIST")
    }
}
