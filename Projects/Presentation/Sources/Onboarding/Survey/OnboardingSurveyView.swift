//
//  OnboardingSurveyView.swift
//  Presentation
//
//  Created by 이정원 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct OnboardingSurveyView: View {
    private let store: StoreOf<OnboardingSurveyFeature>

    public init(store: StoreOf<OnboardingSurveyFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("온보딩 시작 화면")
    }
}
