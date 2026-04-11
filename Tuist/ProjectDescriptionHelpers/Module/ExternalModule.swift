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
    
    var name: String {
        switch self {
        case .alamofire: "Alamofire"
        case .composableArchitecture: "ComposableArchitecture"
        case .dependencies: "Dependencies"
        }
    }
}
