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
    case fetchRecordPage(missionId: Int)
    case completeDaily(missionId: Int, request: MissionCompleteRequestDTO)
    case completeRecommended(missionId: Int, request: MissionCompleteRequestDTO)
    case completeSelected(missionId: Int, request: MissionCompleteRequestDTO)
    case fetchCompletions(missionId: Int)
    case fetchRecommendedMissions
    case fetchRecommendedMissionAvailability
    case fetchSearchedMission
    case searchMission(request: MissionSearchRequestDTO)

    var path: String {
        switch self {
        case let .fetchRecordPage(missionId):
            "/api/v1/missions/\(missionId)/record"
        case let .completeDaily(missionId, _):
            "/api/v1/missions/\(missionId)/complete/daily"
        case let .completeRecommended(missionId, _):
            "/api/v1/missions/\(missionId)/complete/recommended"
        case let .completeSelected(missionId, _):
            "/api/v1/missions/\(missionId)/complete/selected"
        case let .fetchCompletions(missionId):
            "/api/v1/missions/\(missionId)/completions"
        case .fetchRecommendedMissions:
            "/api/v1/missions/recommended"
        case .fetchRecommendedMissionAvailability:
            "/api/v1/missions/recommended/availability"
        case .fetchSearchedMission:
            "/api/v1/missions/selected/today"
        case .searchMission:
            "/api/v1/missions/selected"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchRecordPage: .get
        case .fetchCompletions: .get
        case .fetchRecommendedMissions: .get
        case .fetchSearchedMission: .get
        case .fetchRecommendedMissionAvailability: .get
        case .completeDaily, .completeRecommended, .completeSelected, .searchMission: .post
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .searchMission(request: request):
            request.queryItems
        default: nil
        }
    }

    var body: Encodable? {
        switch self {
        case let .completeDaily(_, request): request
        case let .completeRecommended(_, request): request
        case let .completeSelected(_, request): request
        default: nil
        }
    }
}
