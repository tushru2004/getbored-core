// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GetBoredCore",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "GetBoredCore",
            targets: ["GetBoredCore"]
        ),
    ],
    targets: [
        .target(
            name: "GetBoredCore",
            path: "Sources/GetBoredCore",
            resources: [
                .copy("system-allowed.json"),
            ]
        ),
        .testTarget(
            name: "CoreContractTests",
            dependencies: ["GetBoredCore"],
            path: "tests/CoreContractTests",
            resources: [
                .copy("Fixtures"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
