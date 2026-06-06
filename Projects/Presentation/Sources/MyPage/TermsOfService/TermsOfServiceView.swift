//
//  TermsOfServiceView.swift
//  Presentation
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct TermsOfServiceView: View {
    private let store: StoreOf<TermsOfServiceFeature>

    public init(store: StoreOf<TermsOfServiceFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            if let terms = store.termsOfService {
                VStack(spacing: 36) {
                    ForEach(terms.indices, id: \.self) { index in
                        termsOfServiceInfoView(terms[index])
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationBar(title: "이용약관") {
            store.send(.backButtonTapped)
        }
        .background(Color.white)
        .loading(isLoading: store.isLoading)
    }
}

private extension TermsOfServiceView {
    func termsOfServiceInfoView(_ info: DocumentInfo) -> some View {
        VStack(spacing: 12) {
            if let title = info.title {
                Text(title)
                    .font(.headline2Medium)
                    .foregroundStyle(Color.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }

            Text(info.content)
                .font(.caption1Regular)
                .foregroundStyle(Color.gray700)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
}
