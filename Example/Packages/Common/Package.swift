// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Common",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "CommonScene", targets: ["CommonScene"]),
        .library(name: "CommonUIKit", targets: ["CommonUIKit"]),
    ],
    dependencies: [
        .package(path: "../SharedKit"),
        .package(path: "../../../"),
    ],
    targets: [
        .target(
            name: "CommonScene",
            dependencies: [
                "SharedKit",
                .product(name: "NavigationCoordinator", package: "marcorable-mvvm"),
            ],
            path: "Sources/Scene"
        ),
        .target(
            name: "CommonUIKit",
            dependencies: [
                .product(name: "NavigationCoordinator", package: "marcorable-mvvm"),
            ],
            path: "Sources/UIKit"
        ),
        .testTarget(
            name: "CommonTests",
            dependencies: ["CommonScene"],
            path: "Tests"
        )
    ]
)
