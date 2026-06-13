//
//  RemoteImage.swift
//  DesignSystem
//
//  Created by 송민교 on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Kingfisher
import SwiftUI

public enum ImagePrefetchService {
    public static func prefetch(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        ImagePrefetcher(urls: urls).start()
    }
}

public struct RemoteImage: View {
    private let url: URL?
    private let contentMode: SwiftUI.ContentMode

    public init(url: URL?, contentMode: SwiftUI.ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }

    public var body: some View {
        GeometryReader { proxy in
            KFImage(url)
                .setProcessor(
                    DownsamplingImageProcessor(size: proxy.size)
                )
                .scaleFactor(UIScreen.main.scale)
                .placeholder {
                    Color.gray100
                }
                .fade(duration: 0.25)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        }
    }
}
