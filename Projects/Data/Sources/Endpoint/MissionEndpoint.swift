//
//  MissionEndpoint.swift
//  Data
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Foundation

enum MissionEndpoint: APIEndpoint {
    case complete(missionId: Int, request: MissionCompleteRequestDTO)
    case fetchCompletions(missionId: Int)

    var path: String {
        switch self {
        case let .complete(missionId, _):
            "/api/v1/missions/\(missionId)/complete"
        case let .fetchCompletions(missionId):
            "/api/v1/missions/\(missionId)/completions"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .complete: .post
        case .fetchCompletions: .get
        }
    }

    var body: Encodable? {
        switch self {
        case let .complete(_, request):
            request
        case .fetchCompletions:
            nil
        }
    }
}
