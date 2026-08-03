import ProjectDescription

let project = Project(
    name: "UIKitCombine",
    packages: [
        .local(path: "../../Packages/SharedKit")
    ],
    targets: [
        .target(
            name: "UIKitCombine",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.marcorable.mvvm.uikitcombine",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Sources"],
            dependencies: [
                .package(product: "SharedKit")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
                "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
            ])
        ),
        .target(
            name: "UIKitCombineTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.marcorable.mvvm.uikitcombine.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "UIKitCombine")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES"
            ])
        ),
    ]
)
