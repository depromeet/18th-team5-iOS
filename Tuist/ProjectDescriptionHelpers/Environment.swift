//
//  Environment.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/3/26.
//


enum Environment {
    case dev
    case prod
    
    var name: String {
        switch self {
        case .dev: "Dev"
        case .prod: "Prod"
        }
    }
}
