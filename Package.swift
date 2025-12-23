// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CRTEffectsKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "CRTEffectsKit",
            targets: ["CRTEffectsKit"]
        ),
    ],
    targets: [
        .target(
            name: "CRTEffectsKit",
            resources: [
                .process("Shaders")
            ]
        ),
        .testTarget(
            name: "CRTEffectsKitTests",
            dependencies: ["CRTEffectsKit"]
        ),
    ]
)
