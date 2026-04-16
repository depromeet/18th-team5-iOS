// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers
    
    let packageSettings = PackageSettings(
        productTypes: [:],
        baseSettings: .settings(configurations: .default)
    )
#endif

let package = Package(
    name: "Orange",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.1"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.25.5"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.9.2"),
    ]
)
