//
//  ImageUploadRepositoryImpl.swift
//  Data
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

extension ImageUploadRepository: @retroactive DependencyKey {
    public static let liveValue: ImageUploadRepository = ImageUploadRepositoryImpl.live()
}

public enum ImageUploadRepositoryImpl {
    public static func live() -> ImageUploadRepository {
        ImageUploadRepository(
            uploadImage: { imageData, fileName, contentType in
                @Dependency(\.s3Client) var s3Client

                let (presignedUrl, objectKey) = try await s3Client.fetchPresignedUrl(
                    fileName,
                    contentType
                )
                try await s3Client.uploadImage(presignedUrl, imageData, contentType)
                return objectKey
            }
        )
    }
}
