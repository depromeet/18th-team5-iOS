//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

public final class UserRepositoryImpl: UserRepository {
    private let client: NetworkClient

    public init() {
        self.client = .shared
    }

    init(client: NetworkClient) {
        self.client = client
    }

    public func fetchUsers() async throws -> [User] {
        let dtos: [UserResponseDTO] = try await client.request(UserEndpoint.fetchUsers)
        return dtos.map { $0.toDomain() }
    }

    public func fetchUser(id: Int) async throws -> User {
        let dto: UserResponseDTO = try await client.request(UserEndpoint.fetchUser(id: id))
        return dto.toDomain()
    }
}
