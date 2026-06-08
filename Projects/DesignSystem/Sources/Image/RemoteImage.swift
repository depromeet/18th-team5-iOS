//
//  RemoteImage.swift
//  DesignSystem
//
//  Created by 송민교 on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Kingfisher
import SwiftUI

public struct RemoteImage: View {
    private let url: URL?
    private let contentMode: SwiftUI.ContentMode

    public init(url: URL?, contentMode: SwiftUI.ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }

    public var body: some View {
        KFImage(url)
            .placeholder {
                Color.gray100
            }
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}
