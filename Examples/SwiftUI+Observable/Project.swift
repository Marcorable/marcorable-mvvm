import ProjectDescription

let project = Project(
    name: "SwiftUI+Observable",
    packages: [
        .local(path: "../../Packages/SharedKit"),
        .local(path: "../../Packages/DesignSystem"),
        .local(path: "../../Packages/MarcorableMVVM"),
    ],
    targets: [
        .target(
            name: "SwiftUI+Observable",
            destinations: [.iPhone],
            product: .app,
            productName: "SwiftUIObservable",
            bundleId: "com.marcorable.mvvm.swiftuiobservable",
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
                // 홈 화면에는 '+' 포함 이름을 그대로 보여준다.
                "INFOPLIST_KEY_CFBundleDisplayName": "SwiftUI+Observable",
            ])
        ),
        .target(
            name: "SwiftUI+ObservableTests",
            destinations: [.iPhone],
            product: .unitTests,
            productName: "SwiftUIObservableTests",
            bundleId: "com.marcorable.mvvm.swiftuiobservable.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: nil,
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "SwiftUI+Observable")
            ],
            settings: .settings(base: [
                "GENERATE_INFOPLIST_FILE": "YES",
            ])
        ),
    ]
)
