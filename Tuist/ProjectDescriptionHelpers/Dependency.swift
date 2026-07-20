//
//  Dependency.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/4/26.
//

import ProjectDescription

extension Module {
    var dependencies: [TargetDependency] {
        dependentModules.map(\.dependency)
            + dependentExternalModules.map(\.dependency)
            + sdkDependencies
    }

    var demoDependencies: [TargetDependency] {
        demoDependentExternalModules.map(\.dependency)
    }
}

private extension Module {
    var dependentModules: [Module] {
        switch self {
        case .app: [.presentation, .data]
        case .presentation: [.domain, .designSystem, .camera]
        case .domain: [.core]
        case .data: [.domain, .core]
        case .designSystem: [.core]
        case .camera: [.core]
        default: []
        }
    }
    
    var dependentExternalModules: [ExternalModule] {
        switch self {
        case .app: [.firebaseCore, .firebaseCrashlytics, .firebaseMessaging, .firebaseRemoteConfig]
        case .presentation: [.composableArchitecture, .firebaseRemoteConfig, .kingfisher, .swiftUIIntrospect]
        case .domain: [.dependencies, .dependenciesMacros]
        case .data: [
            .alamofire,
            .dependencies,
            .dependenciesMacros,
            .firebaseAnalytics,
            .firebaseCore,
            .firebaseMessaging,
            .firebaseRemoteConfig,
            .firebaseStorage
        ]
        case .designSystem: [.kingfisher, .lottie]
        case .core: [.dependencies]
        case .camera: []
        }
    }

    var demoDependentExternalModules: [ExternalModule] {
        switch self {
        case .camera: [.composableArchitecture]
        default: []
        }
    }

    var sdkDependencies: [TargetDependency] {
        switch self {
        case .presentation: [.sdk(name: "PhotosUI", type: .framework)]
        case .data: [.sdk(name: "Photos", type: .framework)]
        default: []
        }
    }

    var dependency: TargetDependency {
        TargetDependency.project(
            target: name,
            path: .relativeToRoot("Projects/\(name)")
        )
    }
}

extension ExternalModule {
    var dependency: TargetDependency {
        TargetDependency.external(name: name)
    }
}
