import ProjectDescription

let project = Project(
    name: "SwiftUIObservable",
    packages: [
        .local(path: "../../Packages/SharedKit")
    ],
    targets: [
        .target(
            name: "SwiftUIObservable",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.marcorable.mvvm.swiftuiobservable",
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
            name: "SwiftUIObservableTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.marcorable.mvvm.swiftuiobservable.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "SwiftUIObservable")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES"
            ])
        ),
    ]
)
