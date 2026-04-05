//
//  ProjectInfo.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/3/26.
//

import ProjectDescription

public enum ProjectInfo {
    public static let appName: String = "Orange" // TODO: 추후에 변경 예정 - @정원
    public static let organizationName: String = "Orange"
    public static let destinations: Destinations = [.iPhone]
    public static let deploymentTargets: DeploymentTargets = .iOS("17.0")
}
