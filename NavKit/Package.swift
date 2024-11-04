// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NavKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "NavKit",
            targets: ["NavKit"]
        ),
    ],
    targets: [
        .target(
            name: "NavKit"
        ),
    ]
)

