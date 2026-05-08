//
//  UserEndpoint.swift
//  Data
//
//  Created by 이정원 on 5/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire

enum UserEndpoint: APIEndpoint {
    case fetchUserInfo
    case submitOnboardingInfo(OnboardingRequestDTO)

    var path: String {
        switch self {
        case .fetchUserInfo: "/api/v1/users/me"
        case .submitOnboardingInfo: "/api/v1/users/onboarding"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchUserInfo: .get
        case .submitOnboardingInfo: .post
        }
    }

    var body: Encodable? {
        switch self {
        case .fetchUserInfo: nil
        case let .submitOnboardingInfo(body): body
        }
    }
}
