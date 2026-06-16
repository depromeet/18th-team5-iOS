//
//  CardImageRenderer.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Domain
import Kingfisher
import SwiftUI
import UIKit

/// 기록 카드를 사진 라이브러리 저장·공유용 PNG 데이터로 렌더링하는 의존성.
///
/// 카드 사진은 화면 표시 시 Kingfisher가 캐시해 둔 원본을 우선 사용하고, 캐시에 없을 때만
/// 네트워크로 폴백합니다. (presigned URL은 서명에 쓰인 STS 토큰이 만료되면 재다운로드가 실패하므로,
/// 캐시 히트 경로가 만료 영향을 받지 않게 합니다.) 이렇게 얻은 `UIImage`를 `ImageRenderer`로
/// 화면 표시와 동일한 카드 뷰(`RecordCardBody`)에 합성합니다.
@DependencyClient
struct CardImageRenderer: Sendable {
    var render: @Sendable (_ card: DateRecordCard, _ term: SolarTerm) async throws -> Data
}

enum CardImageRenderError: Error {
    case renderingFailed
}

// MARK: - Live

extension CardImageRenderer: DependencyKey {
    static let liveValue = CardImageRenderer(
        render: { card, term in
            var photo: UIImage?
            if let url = card.imageURL {
                // 1) 캐시(메모리→디스크)만 우선 조회. 화면 표시(KFImage)가 .cacheOriginalImage()로
                //    저장해 둔 원본과 동일 키로 히트하므로, presigned URL 만료의 영향을 받지 않는다.
                let cached = try? await KingfisherManager.shared.retrieveImage(
                    with: url,
                    options: [.onlyFromCache]
                )
                photo = cached?.image

                // 2) 캐시에 없을 때만 네트워크로 폴백.
                if photo == nil {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    photo = UIImage(data: data)
                }
            }
            return try await renderCardImage(card: card, term: term, photo: photo)
        }
    )

    @MainActor
    private static func renderCardImage(card: DateRecordCard, term: SolarTerm, photo: UIImage?) throws -> Data {
        let width = RecordCardLayout.cardBaseWidth
        let height = RecordCardLayout.cardBaseWidth * RecordCardLayout.cardRatio

        let content = RecordCardBody(
            term: term,
            card: card,
            cardWidth: width,
            imageSource: .decoded(photo)
        )
        .frame(width: width, height: height)

        let renderer = ImageRenderer(content: content)
        renderer.scale = UIScreen.main.scale

        guard let uiImage = renderer.uiImage, let data = uiImage.pngData() else {
            throw CardImageRenderError.renderingFailed
        }
        return data
    }
}

// MARK: - Test

extension CardImageRenderer: TestDependencyKey {
    static let testValue = CardImageRenderer()
}

extension DependencyValues {
    var cardImageRenderer: CardImageRenderer {
        get { self[CardImageRenderer.self] }
        set { self[CardImageRenderer.self] = newValue }
    }
}
