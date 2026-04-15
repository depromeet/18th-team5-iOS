//
//  UserResponseDTO.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

struct UserResponseDTO: Decodable {
    let id: Int
    let name: String
    let email: String
}

extension UserResponseDTO {
    func toDomain() -> User {
        User(id: id, name: name, email: email)
    }
}
