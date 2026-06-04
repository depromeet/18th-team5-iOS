//
//  RemoteImage.swift
//  DesignSystem
//
//  Created by 송민교 on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct RemoteImage: View {
    private let url: URL?
    private let contentMode: ContentMode

    public init(url: URL?, contentMode: ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }

    public var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } placeholder: {
            Color.gray100
        }
    }
}
