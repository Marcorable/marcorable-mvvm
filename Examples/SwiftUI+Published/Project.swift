import ProjectDescription

let project = Project(
    name: "SwiftUI+Published",
    packages: [
        .local(path: "../../Packages/SharedKit"),
        .local(path: "../../Packages/DesignSystem"),
        .local(path: "../../Packages/MarcorableMVVM"),
    ],
    targets: [
        .target(
            name: "SwiftUI+Published",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.marcorable.mvvm.swiftuipublished",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Sources"],
            dependencies: [
                .package(product: "SharedKit"),
                .package(product: "DesignSystem"),
                .package(product: "MarcorableMVVM"),
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
                "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                // '+'는 Swift 모듈명에 쓸 수 없으므로 모듈명을 따로 지정한다.
                "PRODUCT_MODULE_NAME": "SwiftUIPublished",
            ])
        ),
        .target(
            name: "SwiftUI+PublishedTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.marcorable.mvvm.swiftuipublished.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "SwiftUI+Published")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
                "PRODUCT_MODULE_NAME": "SwiftUIPublishedTests",
            ])
        ),
    ]
)
