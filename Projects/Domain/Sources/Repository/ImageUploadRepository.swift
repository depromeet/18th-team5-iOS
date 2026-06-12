//
//  ImageUploadRepository.swift
//  Domain
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct ImageUploadRepository: Sendable {
    public var uploadImage: @Sendable (
        _ imageData: Data,
        _ fileName: String,
        _ contentType: String
    ) async throws -> String
}

extension ImageUploadRepository: TestDependencyKey {
    public static let testValue = ImageUploadRepository()
}

public extension DependencyValues {
    var imageUploadRepository: ImageUploadRepository {
        get { self[ImageUploadRepository.self] }
        set { self[ImageUploadRepository.self] = newValue }
    }
}
