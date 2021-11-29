// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "RequestKit",
    products: [
        .library(name: "RequestKit", targets: ["RequestKit"]),
    ],
    targets: [
        .target(name: "RequestKit", dependencies: []),
        .testTarget(name: "RequestKitTests", dependencies: ["RequestKit"]),
    ],
    swiftLanguageVersions: [.version("3.0"), .version("4.0"), .version("4.1"), .version("4.2")]
)
