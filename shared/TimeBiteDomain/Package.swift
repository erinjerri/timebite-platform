// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TimeBiteDomain",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "TimeBiteDomain", targets: ["TimeBiteDomain"]),
    ],
    targets: [
        .target(
            name: "TimeBiteDomain",
            dependencies: []
        ),
        .testTarget(
            name: "TimeBiteDomainTests",
            dependencies: ["TimeBiteDomain"]
        ),
    ]
)

