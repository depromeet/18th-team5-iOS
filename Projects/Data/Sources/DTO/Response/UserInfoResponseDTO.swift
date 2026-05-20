//
//  UserInfoResponseDTO.swift
//  Data
//
//  Created by 이정원 on 5/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

struct UserInfoResponseDTO: Decodable {
    let userId: Int
    let nickname: String?
    let onboardingCompleted: Bool
    let userType: String?
}
