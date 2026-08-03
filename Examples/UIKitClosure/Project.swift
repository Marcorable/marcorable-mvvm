import ProjectDescription

let project = Project(
    name: "UIKitClosure",
    packages: [
        .local(path: "../../Packages/SharedKit")
    ],
    targets: [
        .target(
            name: "UIKitClosure",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.marcorable.mvvm.uikitclosure",
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
            name: "UIKitClosureTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.marcorable.mvvm.uikitclosure.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "UIKitClosure")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES"
            ])
        ),
    ]
)
