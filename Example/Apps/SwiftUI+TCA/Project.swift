
import ProjectDescription

let project = Project(
    name: "SwiftUI+TCA",
    options: .options(defaultKnownRegions: ["en"]),
    packages: [
        .local(path: "../../Packages/SharedKit"),
        .local(path: "../../../"),
        .local(path: "../../Packages/Common"),
        .remote(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            requirement: .upToNextMajor(from: "1.25.0")
        ),
    ],
    targets: [
        .target(
            name: "SwiftUI+TCA",
            destinations: [.iPhone],
            product: .app,
            productName: "SwiftUITCA",
            bundleId: "com.marcorable.mvvm.swiftuitca",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Sources"],
            dependencies: [
                .package(product: "SharedKit"),
                .package(product: "NavigationCoordinator"),
                .package(product: "CommonScene"),
                .package(product: "ComposableArchitecture"),
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
                "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                "INFOPLIST_KEY_CFBundleDisplayName": "SwiftUI+TCA",
            ])
        ),
        .target(
            name: "SwiftUI+TCATests",
            destinations: [.iPhone],
            product: .unitTests,
            productName: "SwiftUITCATests",
            bundleId: "com.marcorable.mvvm.swiftuitca.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "SwiftUI+TCA")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
            ])
        ),
    ],
    additionalFiles: [
        "README.md",
    ]
)
