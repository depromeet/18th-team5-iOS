//
//  ExternalModule.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/4/26.
//

import ProjectDescription

enum ExternalModule {
    case alamofire
    case composableArchitecture
    case dependencies
	case dependenciesMacros
    case firebaseCore
    case firebaseMessaging
    case firebaseRemoteConfig
    case kingfisher
    
    var name: String {
        switch self {
        case .alamofire: "Alamofire"
        case .composableArchitecture: "ComposableArchitecture"
        case .dependencies: "Dependencies"
		case .dependenciesMacros: "DependenciesMacros"
        case .firebaseCore: "FirebaseCore"
        case .firebaseMessaging: "FirebaseMessaging"
        case .firebaseRemoteConfig: "FirebaseRemoteConfig"
        case .kingfisher: "Kingfisher"
        }
    }
}
