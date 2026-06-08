//
//  PrivacyPolicyResponseDTO.swift
//  Data
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

struct PrivacyPolicyResponseDTO: Decodable {
    let title: String?
    let content: String?
}

extension PrivacyPolicyResponseDTO {
    var toDomain: PrivacyPolicyInfo? {
        guard let content else { return nil }
        return .init(title: title, content: content)
    }
}
