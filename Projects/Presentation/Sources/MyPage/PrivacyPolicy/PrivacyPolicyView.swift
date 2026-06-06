//
//  PrivacyPolicyView.swift
//  Presentation
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct PrivacyPolicyView: View {
    private let store: StoreOf<PrivacyPolicyFeature>

    public init(store: StoreOf<PrivacyPolicyFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Privacy Policy")
    }
}
