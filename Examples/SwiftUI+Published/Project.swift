import ProjectDescription

let project = Project(
    name: "SwiftUI+Published",
    packages: [
        .local(path: "../../Packages/SharedKit"),
        .local(path: "../../Packages/MarcorableMVVM"),
        .local(path: "../../Packages/Common"),
    ],
    targets: [
        .target(
            name: "SwiftUI+Published",
            destinations: [.iPhone],
            product: .app,
            productName: "SwiftUIPublished",
            bundleId: "com.marcorable.mvvm.swiftuipublished",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Sources"],
            dependencies: [
                .package(product: "SharedKit"),
                .package(product: "NavigationCoordinator"),
                .package(product: "CommonScene"),
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
                "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                // 홈 화면에는 '+' 포함 이름을 그대로 보여준다.
                "INFOPLIST_KEY_CFBundleDisplayName": "SwiftUI+Published",
            ])
        ),
        .target(
            name: "SwiftUI+PublishedTests",
            destinations: [.iPhone],
            product: .unitTests,
            productName: "SwiftUIPublishedTests",
            bundleId: "com.marcorable.mvvm.swiftuipublished.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "SwiftUI+Published")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
            ])
        ),
    ]
)
