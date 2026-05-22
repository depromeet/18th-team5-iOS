//
//  Module.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/3/26.
//

import ProjectDescription

public enum Module {
    case app
    case presentation
    case domain
    case data
    case designSystem
    case core
    case camera

    var name: String {
        switch self {
        case .app: "App"
        case .presentation: "Presentation"
        case .domain: "Domain"
        case .data: "Data"
        case .designSystem: "DesignSystem"
        case .core: "Core"
        case .camera: "Camera"
        }
    }
    
    var bundleID: String {
        if case .app = self { return "${PRODUCT_BUNDLE_IDENTIFIER}" }
        let appName = ProjectInfo.appName
        return "com.\(appName).\(name)".lowercased()
    }
}
