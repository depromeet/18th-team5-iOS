//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/4/26.
//

import ProjectDescription

extension Project {
    public init(module: Module) {
        self = Project(
            name: module.name,
            organizationName: ProjectInfo.organizationName,
            options: .options(automaticSchemesOptions: .disabled),
            settings: module.settings,
            targets: module.targets,
            schemes: module.schemes,
            additionalFiles: module.additionalFiles,
            resourceSynthesizers: module.resourceSynthesizers
        )
    }
}

private extension Module {
    var targets: [Target] {
        switch self {
        case .app: [.app]
        case .presentation: [implements, tests, demo]
        case .designSystem: [implements, demo]
        case .data, .domain, .core: [implements, tests]
        }
    }
    
    var schemes: [Scheme] {
        switch self {
        case .app: [.app(.dev), .app(.prod)]
        case .presentation: [testScheme, demoScheme]
        case .designSystem: [demoScheme]
        case .data, .domain, .core: [testScheme]
        }
    }
    
    var additionalFiles: [FileElement] {
        switch self {
        case .app: [.glob(pattern: .relativeToRoot("Configs/Shared.xcconfig"))]
        default: []
        }
    }
    
    var resourceSynthesizers: [ResourceSynthesizer] {
        switch self {
        case .designSystem: [.fonts(), .images, .colors]
        default: []
        }
    }
    
    var settings: Settings {
        switch self {
        case .app:
            .settings(
                base: [
                    "OTHER_LDFLAGS": "-ObjC"
                ],
                configurations: .default
            )
        default:
            .settings(configurations: .default)
        }
    }
}

private extension ResourceSynthesizer {
    static let images: Self = .custom(name: "Images", parser: .assets, extensions: ["xcassets"])
    static let colors: Self = .custom(name: "Colors", parser: .assets, extensions: ["xcassets"])
}
