//
//  SolarTermIntroRepositoryImpl.swift
//  Data
//
//  Created by 송민교 on 5/19/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import FirebaseStorage
import Foundation

extension SolarTermIntroRepository: @retroactive DependencyKey {
    public static let liveValue: SolarTermIntroRepository = SolarTermIntroRepositoryImpl.live()
}

public enum SolarTermIntroRepositoryImpl {
    public static func live() -> SolarTermIntroRepository {
        let storage = Storage.storage()

        return SolarTermIntroRepository(
            fetchSolarTermCard: {
                let ref = storage.reference().child("solar_terms.json")
                let data = try await ref.data(maxSize: 1 * 1024 * 1024) // 1MB 제한
                let dto = try JSONDecoder().decode(SolarTermIntroFileDTO.self, from: data)
                return dto.toDomain()
            },
            fetchImageURL: { path in
                let ref = Storage.storage().reference().child(path)
                return try await ref.downloadURL()
            },
            fetchContentImageURLs: { contents in
                await withTaskGroup(of: (String, [URL]).self) { group in
                    for content in contents {
                        group.addTask {
                            var urls: [URL] = []
                            for path in content.imageURLs {
                                if let url = try? await storage.reference().child(path).downloadURL() {
                                    urls.append(url)
                                }
                            }
                            return (content.id, urls)
                        }
                    }
                    var urlDictionary: [String: [URL]] = [:]
                    for await (id, urls) in group {
                        urlDictionary[id] = urls
                    }
                    return urlDictionary
                }
            }
        )
    }
}
