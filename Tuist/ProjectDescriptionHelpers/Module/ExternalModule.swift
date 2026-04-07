//
//  ExternalModule.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/4/26.
//

import ProjectDescription

enum ExternalModule {
    case alamofire
    
    var name: String {
        switch self {
        case .alamofire: "Alamofire"
        }
    }
}
