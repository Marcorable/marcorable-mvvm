// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarcorableMVVM",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MarcorableMVVM", targets: ["MarcorableMVVM"])
    ],
    targets: [
        // 단일 타깃이므로 기본 규칙(Sources/<타깃명>/) 대신 Sources/를 바로 사용한다.
        .target(name: "MarcorableMVVM", path: "Sources")
    ]
)
