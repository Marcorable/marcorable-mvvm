// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarcorableMVVM",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "NavigationCoordinator", targets: ["NavigationCoordinator"])
    ],
    targets: [
        .target(name: "NavigationCoordinator", path: "Sources/NavigationCoordinator")
    ]
)
