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
            settings: .settings(configurations: .default),
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
        case .camera: [implements, demo]
        }
    }

    var schemes: [Scheme] {
        switch self {
        case .app: [.app(.dev), .app(.prod)]
        case .presentation: [testScheme, demoScheme]
        case .designSystem: [demoScheme]
        case .data, .domain, .core: [testScheme]
        case .camera: [demoScheme]
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
        case .designSystem: [.fonts(), .images, .colors, .lottie]
        default: []
        }
    }
}

private extension ResourceSynthesizer {
    static let images: Self = .custom(name: "Images", parser: .assets, extensions: ["xcassets"])
    static let colors: Self = .custom(name: "Colors", parser: .assets, extensions: ["xcassets"])
    static let lottie: Self = .custom(name: "Lottie", parser: .files, extensions: ["lottie"])
}
