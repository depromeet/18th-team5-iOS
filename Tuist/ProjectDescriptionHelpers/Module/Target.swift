//
//  Target.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/3/26.
//

import ProjectDescription

// MARK: - Lint Scripts

private let lintScripts: [TargetScript] = [
    .pre(
        script: """
        if command -v swiftformat >/dev/null 2>&1; then
            swiftformat . --quiet
        fi
        """,
        name: "SwiftFormat",
        basedOnDependencyAnalysis: false
    ),
    .pre(
        script: """
        if command -v swiftlint >/dev/null 2>&1; then
            swiftlint lint --fix --quiet
            swiftlint lint --quiet
        fi
        """,
        name: "SwiftLint",
        basedOnDependencyAnalysis: false
    ),
]

extension Target {
    static var app: Target {
        let module = Module.app
        return .target(
            name: module.name,
            destinations: ProjectInfo.destinations,
            product: .app,
            bundleId: module.bundleID,
            deploymentTargets: ProjectInfo.deploymentTargets,
            infoPlist: .file(path: "Info.plist"),
            buildableFolders: module.buildableFolders,
            scripts: lintScripts,
            dependencies: module.dependencies,
            settings: .settings(configurations: .default)
        )
    }
}

extension Module {
    var implements: Target {
        return .target(
            name: name,
            destinations: ProjectInfo.destinations,
            product: product,
            bundleId: bundleID,
            deploymentTargets: ProjectInfo.deploymentTargets,
            buildableFolders: buildableFolders,
            scripts: lintScripts,
            dependencies: dependencies,
            settings: .settings(configurations: .default)
        )
    }
    
    var tests: Target {
        return .target(
            name: "\(name)Tests",
            destinations: ProjectInfo.destinations,
            product: .unitTests,
            bundleId: "\(bundleID)Tests",
            deploymentTargets: ProjectInfo.deploymentTargets,
            buildableFolders: ["Tests"],
            scripts: lintScripts,
            dependencies: [.target(implements)],
            settings: .settings(configurations: .default)
        )
    }
    
    var demo: Target {
        return .target(
            name: "\(name)Demo",
            destinations: ProjectInfo.destinations,
            product: .app,
            bundleId: "\(bundleID)Demo",
            deploymentTargets: ProjectInfo.deploymentTargets,
            buildableFolders: ["Demo/Sources"],
            scripts: lintScripts,
            dependencies: [.target(implements)],
            settings: .settings(configurations: .default)
        )
    }
}

private extension Module {
    var product: Product {
        switch self {
        case .app: .app
        case .presentation, .data, .designSystem, .domain, .core: .staticFramework
        }
    }
    
    var buildableFolders: [BuildableFolder] {
        switch self {
        case .app, .designSystem: ["Sources", "Resources"]
        default: ["Sources"]
        }
    }
}
