// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnackbarKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SnackbarKit",
            targets: ["SnackbarKit"]
        )
    ],
    targets: [
        .target(
            name: "SnackbarKit",
            path: "SnackbarKit"
        ),
        .testTarget(
            name: "SnackbarKitTests",
            dependencies: ["SnackbarKit"]
        )
    ]
)
