//
//  ProjectInfo.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/3/26.
//

import ProjectDescription

public enum ProjectInfo {
    public static let appName: String = "Peaktime"
    public static let organizationName: String = "Orange"
    public static let destinations: Destinations = [.iPhone]
    public static let deploymentTargets: DeploymentTargets = .iOS("18.0")
}
