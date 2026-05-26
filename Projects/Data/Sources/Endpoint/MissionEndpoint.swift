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
    case fetchSearchedMission

    var path: String {
        switch self {
        case let .complete(missionId, _):
            "/api/v1/missions/\(missionId)/complete/daily"
        case let .fetchCompletions(missionId):
            "/api/v1/missions/\(missionId)/completions"
        case .fetchSearchedMission:
            "/api/v1/missions/selected/today"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .complete: .post
        case .fetchCompletions: .get
        case .fetchSearchedMission: .get
        }
    }

    var body: Encodable? {
        switch self {
        case let .complete(_, request): request
        case .fetchCompletions: nil
        case .fetchSearchedMission: nil
        }
    }
}
