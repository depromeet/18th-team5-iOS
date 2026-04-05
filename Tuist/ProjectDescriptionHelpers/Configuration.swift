//
//  Configuration.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/3/26.
//

import ProjectDescription

extension ConfigurationName {
    static func debug(_ environment: Environment) -> ConfigurationName {
        ConfigurationName.configuration("Debug\(environment.name)")
    }
    
    static func release(_ environment: Environment) -> ConfigurationName {
        ConfigurationName.configuration("Release\(environment.name)")
    }
}

public extension [Configuration] {
    static let `default`: [Configuration] = [
        .debug(name: .debug(.dev), xcconfig: .path(.dev)),
        .debug(name: .debug(.prod), xcconfig: .path(.prod)),
        .release(name: .release(.dev), xcconfig: .path(.dev)),
        .release(name: .release(.prod), xcconfig: .path(.prod))
    ]
}

private extension ProjectDescription.Path {
    static func path(_ environment: Environment) -> ProjectDescription.Path {
        return .relativeToRoot("Configs/\(environment.name).xcconfig")
    }
}
