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
    case firebaseAnalytics
    case firebaseCore
    case firebaseCrashlytics
    case firebaseMessaging
    case firebaseRemoteConfig
    case firebaseStorage
    case kingfisher
    case lottie
    case swiftUIIntrospect

    var name: String {
        switch self {
        case .alamofire: "Alamofire"
        case .composableArchitecture: "ComposableArchitecture"
        case .dependencies: "Dependencies"
		case .dependenciesMacros: "DependenciesMacros"
        case .firebaseAnalytics: "FirebaseAnalytics"
        case .firebaseCore: "FirebaseCore"
        case .firebaseCrashlytics: "FirebaseCrashlytics"
        case .firebaseMessaging: "FirebaseMessaging"
        case .firebaseRemoteConfig: "FirebaseRemoteConfig"
        case .firebaseStorage: "FirebaseStorage"
        case .kingfisher: "Kingfisher"
        case .lottie: "Lottie"
        case .swiftUIIntrospect: "SwiftUIIntrospect"
        }
    }
}
