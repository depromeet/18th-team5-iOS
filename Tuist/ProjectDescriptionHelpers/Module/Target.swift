//
//  Target.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정원 on 4/3/26.
//

import ProjectDescription

// MARK: - Lint Scripts

// 빌드 스크립트에서는 lint 경고 표시만 수행 (파일 수정 없음)
// 자동 수정(--fix)은 pre-commit hook에서 처리하여 incremental build 안정성 확보
// app 타겟에서만 ${SRCROOT} 전체를 린트하므로 다른 타겟에는 부착하지 않음
private extension TargetScript {
    static let lint: TargetScript = .pre(
        script: """
        if command -v swiftlint >/dev/null 2>&1; then
            swiftlint lint --quiet "${SRCROOT}"
        fi
        """,
        name: "SwiftLint",
        basedOnDependencyAnalysis: false
    )

    static let googleServiceInfo: TargetScript = .pre(
        script: """
        if [ "${ENV}" = "Dev" ]; then
            cp ${PROJECT_DIR}/../../Secrets/GoogleService-Info/Dev/GoogleService-Info.plist \
               ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist
        else
            cp ${PROJECT_DIR}/../../Secrets/GoogleService-Info/Prod/GoogleService-Info.plist \
               ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist
        fi
        """,
        name: "Firebase Config Switch"
    )
}

extension Target {
    static var app: Target {
        let module = Module.app
        return .target(
            name: module.name,
            destinations: ProjectInfo.destinations,
            product: .app,
            bundleId: module.bundleID,
            deploymentTargets: ProjectInfo.deploymentTargets,
            infoPlist: .file(path: "Info.plist"),
            buildableFolders: module.buildableFolders,
            entitlements: "App.entitlements",
            scripts: [
                .lint,
                .googleServiceInfo,
            ],
            dependencies: module.dependencies,
            settings: .settings(configurations: .default)
        )
    }
}

extension Module {
    var implements: Target {
        return .target(
            name: name,
            destinations: ProjectInfo.destinations,
            product: product,
            bundleId: bundleID,
            deploymentTargets: ProjectInfo.deploymentTargets,
            buildableFolders: buildableFolders,
            dependencies: dependencies,
            settings: .settings(configurations: .default)
        )
    }

    var tests: Target {
        return .target(
            name: "\(name)Tests",
            destinations: ProjectInfo.destinations,
            product: .unitTests,
            bundleId: "\(bundleID)Tests",
            deploymentTargets: ProjectInfo.deploymentTargets,
            buildableFolders: ["Tests"],
            dependencies: [.target(implements)],
            settings: .settings(configurations: .default)
        )
    }

    var demo: Target {
        return .target(
            name: "\(name)Demo",
            destinations: ProjectInfo.destinations,
            product: .app,
            bundleId: "\(bundleID)Demo",
            deploymentTargets: ProjectInfo.deploymentTargets,
            infoPlist: demoInfoPlist,
            buildableFolders: ["Demo/Sources"],
            dependencies: [.target(implements)] + demoDependencies,
            settings: .settings(configurations: .default)
        )
    }

    private var demoInfoPlist: InfoPlist {
        switch self {
        case .camera: .cameraDemo
        default: .demo
        }
    }
}

private extension Module {
    var product: Product {
        switch self {
        case .app: .app
        case .presentation, .data, .designSystem, .domain, .core, .camera: .staticFramework
        }
    }

    var buildableFolders: [BuildableFolder] {
        switch self {
        case .app, .designSystem, .data: ["Sources", "Resources"]
        default: ["Sources"]
        }
    }
}

private extension InfoPlist {
    static let demo: InfoPlist = .extendingDefault(
        with: [
            "UILaunchScreen": .dictionary([:]),
            "UISupportedInterfaceOrientations": .array([
                .string("UIInterfaceOrientationPortrait"),
            ])
        ]
    )

    static let cameraDemo: InfoPlist = .extendingDefault(
        with: [
            "UILaunchScreen": .dictionary([:]),
            "UISupportedInterfaceOrientations": .array([
                .string("UIInterfaceOrientationPortrait"),
            ]),
            "NSCameraUsageDescription": .string("카메라 촬영을 위해 접근 권한이 필요합니다."),
        ]
    )
}
