// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSToast",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "JSToast",
            targets: ["JSToast"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "JSToast",
            dependencies: []
        ),
        .testTarget(
            name: "JSToastTests",
            dependencies: ["JSToast"]
        )
    ]
)
