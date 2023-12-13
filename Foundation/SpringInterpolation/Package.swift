// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SpringInterpolation",
    products: [
        .library(
            name: "SpringInterpolation",
            targets: ["SpringInterpolation"]
        ),
    ],
    targets: [
        .target(name: "SpringInterpolation"),
    ]
)
