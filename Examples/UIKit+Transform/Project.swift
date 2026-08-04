import ProjectDescription

let project = Project(
    name: "UIKit+Transform",
    packages: [
        .local(path: "../../Packages/SharedKit"),
        .local(path: "../../Packages/MarcorableMVVM"),
        .local(path: "../../Packages/Common"),
    ],
    targets: [
        .target(
            name: "UIKit+Transform",
            destinations: [.iPhone],
            product: .app,
            productName: "UIKitTransform",
            bundleId: "com.marcorable.mvvm.uikittransform",
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
                // 홈 화면에는 '+' 포함 이름을 그대로 보여준다.
                "INFOPLIST_KEY_CFBundleDisplayName": "UIKit+Transform",
            ])
        ),
        .target(
            name: "UIKit+TransformTests",
            destinations: [.iPhone],
            product: .unitTests,
            productName: "UIKitTransformTests",
            bundleId: "com.marcorable.mvvm.uikittransform.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "UIKit+Transform")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
            ])
        ),
    ]
)
