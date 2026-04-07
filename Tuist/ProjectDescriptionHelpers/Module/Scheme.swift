//
//  Scheme.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/4/26.
//

import ProjectDescription

extension Scheme {
    static func app(_ environment: Environment) -> Scheme {
        let name = Module.app.name
        let schemeName = switch environment {
        case .dev: "\(ProjectInfo.appName) DEV"
        case .prod: ProjectInfo.appName
        }
        
        return .scheme(
            name: schemeName,
            buildAction: .buildAction(targets: [.target(name)]),
            runAction: .runAction(
                configuration: .debug(environment),
                executable: .executable(.target(name))
            ),
            archiveAction: .archiveAction(configuration: .release(environment)),
            profileAction: .profileAction(
                configuration: .release(environment),
                executable: .executable(.target(name))
            ),
            analyzeAction: .analyzeAction(configuration: .debug(environment))
        )
    }
}

extension Module {
    var testScheme: Scheme {
        let name = "\(name)Tests"
        
        return .scheme(
            name: name,
            buildAction: .buildAction(targets: [.target(name)]),
            testAction: .targets(
                [.testableTarget(target: .target(name))],
                configuration: .debug(.dev)
            )
        )
    }
    
    var demoScheme: Scheme {
        let name = "\(name)Demo"
        
        return .scheme(
            name: name,
            buildAction: .buildAction(targets: [.target(name)]),
            runAction: .runAction(
                configuration: .debug(.dev),
                executable: .executable(.target(name))
            )
        )
    }
}
