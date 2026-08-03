import ProjectDescription

let project = Project(
    name: "SwiftUIClassic",
    packages: [
        .local(path: "../../Packages/SharedKit")
    ],
    targets: [
        .target(
            name: "SwiftUIClassic",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.marcorable.mvvm.swiftuiclassic",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Sources"],
            dependencies: [
                .package(product: "SharedKit")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
                "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
            ])
        ),
        .target(
            name: "SwiftUIClassicTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.marcorable.mvvm.swiftuiclassic.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "SwiftUIClassic")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES"
            ])
        ),
    ]
)
