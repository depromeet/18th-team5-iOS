//
//  PhotoLibraryClient.swift
//  Domain
//
//  Created by 진준호 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import CoreGraphics
import Dependencies
import DependenciesMacros
import Foundation

public struct PhotoAsset: Sendable, Equatable, Identifiable {
    public let id: String
    public let creationDate: Date?

    public init(id: String, creationDate: Date?) {
        self.id = id
        self.creationDate = creationDate
    }
}

@DependencyClient
public struct PhotoLibraryClient: Sendable {
    public var fetchAssets: @Sendable () async -> [PhotoAsset] = { [] }
    public var loadThumbnail: @Sendable (_ id: String, _ size: CGSize) async -> Data?
    public var loadFullImage: @Sendable (_ id: String) async -> Data?
    public var observeChanges: @Sendable () -> AsyncStream<Void> = { .finished }
    /// 이미지 데이터를 사진 라이브러리에 새 항목으로 저장한다.
    public var saveImage: @Sendable (_ data: Data) async throws -> Void
}

// MARK: - TestDependencyKey

extension PhotoLibraryClient: TestDependencyKey {
    public static let testValue = PhotoLibraryClient()
}

public extension DependencyValues {
    var photoLibraryClient: PhotoLibraryClient {
        get { self[PhotoLibraryClient.self] }
        set { self[PhotoLibraryClient.self] = newValue }
    }
}
