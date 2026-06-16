//
//  CardImageRenderer.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Domain
import SwiftUI
import UIKit

/// 기록 카드를 사진 라이브러리 저장·공유용 PNG 데이터로 렌더링하는 의존성.
///
/// 카드 사진(presigned URL)을 먼저 내려받아 디코딩한 뒤, `ImageRenderer`로 화면 표시와
/// 동일한 카드 뷰(`RecordCardBody`)를 합성합니다.
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
                let (data, _) = try await URLSession.shared.data(from: url)
                photo = UIImage(data: data)
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
