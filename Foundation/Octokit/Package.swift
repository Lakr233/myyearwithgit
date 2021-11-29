// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "OctoKit",

    products: [
        .library(
            name: "OctoKit",
            targets: ["OctoKit"]
        ),
    ],
    dependencies: [
        .package(path: "../RequestKit"),
    ],
    targets: [
        .target(
            name: "OctoKit",
            dependencies: ["RequestKit"],
            path: "OctoKit"
        ),
        .testTarget(
            name: "OctoKitTests",
            dependencies: ["OctoKit"]
        ),
    ]
)
