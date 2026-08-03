import ProjectDescription

let project = Project(
    name: "CoordinatorMVVM",
    packages: [
        .local(path: "../../Packages/SharedKit")
    ],
    targets: [
        .target(
            name: "CoordinatorMVVM",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.marcorable.mvvm.coordinator",
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
            name: "CoordinatorMVVMTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.marcorable.mvvm.coordinator.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "CoordinatorMVVM")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES"
            ])
        ),
    ]
)
