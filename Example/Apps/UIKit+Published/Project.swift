
import ProjectDescription

let project = Project(
    name: "UIKit+Published",
    options: .options(defaultKnownRegions: ["en"]),
    packages: [
        .local(path: "../../Packages/SharedKit"),
        .local(path: "../../../"),
        .local(path: "../../Packages/Common"),
    ],
    targets: [
        .target(
            name: "UIKit+Published",
            destinations: [.iPhone],
            product: .app,
            productName: "UIKitPublished",
            bundleId: "com.marcorable.mvvm.uikitpublished",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Sources"],
            dependencies: [
                .package(product: "SharedKit"),
                .package(product: "NavigationCoordinator"),
                .package(product: "CommonScene"),
                .package(product: "CommonUIKit"),
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
                "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
                "INFOPLIST_KEY_CFBundleDisplayName": "UIKit+Published",
            ])
        ),
        .target(
            name: "UIKit+PublishedTests",
            destinations: [.iPhone],
            product: .unitTests,
            productName: "UIKitPublishedTests",
            bundleId: "com.marcorable.mvvm.uikitpublished.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "UIKit+Published")
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
