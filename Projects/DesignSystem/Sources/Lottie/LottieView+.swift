//
//  LottieView+.swift
//  DesignSystem
//
//  Created by 이정원 on 7/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Lottie
import SwiftUI

public struct PLottieView: View {
    private let asset: AnimationAsset

    public init(_ asset: AnimationAsset) {
        self.asset = asset
    }

    public var body: some View {
        LottieView {
            try await DotLottieFile.named(
                asset.rawValue,
                bundle: .module
            )
        }
        .looping()
        .resizable()
        .aspectRatio(contentMode: .fit)
    }
}
