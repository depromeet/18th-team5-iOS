//
//  S3Client.swift
//  Data
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct S3Client: Sendable {
    var fetchPresignedUrl: @Sendable (
        _ fileName: String,
        _ contentType: String
    ) async throws -> (presignedUrl: String, objectKey: String)

    var uploadImage: @Sendable (
        _ presignedUrl: String,
        _ imageData: Data,
        _ contentType: String
    ) async throws -> Void
}

extension S3Client: DependencyKey {
    static let liveValue = S3Client(
        fetchPresignedUrl: { fileName, contentType in
            @Dependency(\.networkClient) var client
            let response: PresignedUrlResponseDTO = try await client.request(
                S3Endpoint.presignedUrl(fileName: fileName, contentType: contentType)
            )
            return (response.result.presignedUrl, response.result.objectKey)
        },
        uploadImage: { presignedUrl, imageData, contentType in
            guard let url = URL(string: presignedUrl) else {
                throw NetworkError.invalidURL
            }

            var request = URLRequest(url: url)
            request.method = .put
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData

            do {
                _ = try await AF.request(request)
                    .validate(statusCode: 200 ..< 300)
                    .serializingData(emptyResponseCodes: [200])
                    .value
            } catch let afError as AFError {
                throw afError.toNetworkError()
            } catch let networkError as NetworkError {
                throw networkError
            } catch {
                throw NetworkError.unknown(error.localizedDescription)
            }
        }
    )
}

extension S3Client: TestDependencyKey {
    static let testValue = S3Client()
}

extension DependencyValues {
    var s3Client: S3Client {
        get { self[S3Client.self] }
        set { self[S3Client.self] = newValue }
    }
}
