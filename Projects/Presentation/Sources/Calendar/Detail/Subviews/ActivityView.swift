//
//  ActivityView.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI
import UIKit

/// 공유 시트에 표시할 렌더링된 카드 이미지.
///
/// `CardImageRenderer`가 합성한 PNG 데이터를 보관한다. State 비교 비용을 줄이기 위해
/// 동등성은 생성 시 부여한 `id`로만 판단한다.
public struct ShareImageItem: Identifiable, Equatable {
    public let id: UUID
    public let imageData: Data

    public init(imageData: Data) {
        self.id = UUID()
        self.imageData = imageData
    }

    public static func == (lhs: ShareImageItem, rhs: ShareImageItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// `UIActivityViewController`를 SwiftUI에서 표시하기 위한 래퍼.
///
/// 이미지 공유·복사·저장 등 iOS 기본 공유 시트를 노출한다.
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    /// 공유 시트가 닫힐 때 호출된다. `completed`는 실제로 공유를 완료하면 `true`, 취소하면 `false`.
    var onComplete: ((_ completed: Bool) -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { _, completed, _, _ in
            onComplete?(completed)
        }
        return activityVC
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
