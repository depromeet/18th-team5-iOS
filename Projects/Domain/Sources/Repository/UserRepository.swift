//
//  UserRepository.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public protocol UserRepository {
    func fetchUsers() async throws -> [User]
    func fetchUser(id: Int) async throws -> User
}
