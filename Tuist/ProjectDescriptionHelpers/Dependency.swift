//
//  Dependency.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/4/26.
//

import ProjectDescription

extension Module {
    var dependencies: [TargetDependency] {
        dependentModules.map(\.dependency) + dependentExternalModules.map(\.dependency)
    }
}

private extension Module {
    var dependentModules: [Module] {
        switch self {
        case .app: [.presentation, .data]
        case .presentation: [.domain, .designSystem]
        case .domain: [.core]
        case .data: [.domain]
        case .designSystem: [.core]
        default: []
        }
    }
    
    var dependentExternalModules: [ExternalModule] {
        switch self {
        case .app: [.firebaseRemoteConfig]
        case .presentation: [.composableArchitecture]
        case .domain: [.dependencies, .dependenciesMacros]
        case .data: [.alamofire, .dependencies]
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

private extension ExternalModule {
    var dependency: TargetDependency {
        TargetDependency.external(name: name)
    }
}
